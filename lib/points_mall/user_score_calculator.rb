# frozen_string_literal: true

module PointsMall
  class UserScoreCalculator
    # 重新计算单个用户的积分（同步执行）
    # @param user_id [Integer] 用户ID
    # @return [Boolean] 是否成功执行
    def self.recalculate_user_score(user_id:)
      return false unless defined?(DiscourseGamification::GamificationScore)

      user = User.find_by(id: user_id)
      return false unless user&.active?

      # 获取第一个 leaderboard 的时间范围设置
      leaderboard = DiscourseGamification::GamificationLeaderboard.order(:id).first if defined?(DiscourseGamification::GamificationLeaderboard)
      
      # 确定计算的时间范围
      # 如果 leaderboard 有 from_date，则从 from_date 开始；否则从用户最早的事件日期或10天前开始
      if leaderboard&.from_date
        since_date = leaderboard.from_date
      else
        earliest_event =
          DiscourseGamification::GamificationScoreEvent.where(user_id: user_id).minimum(:date)
        since_date = earliest_event || 10.days.ago.to_date
      end

      # 确定结束日期（如果 leaderboard 有 to_date，则只计算到 to_date；否则计算所有时间）
      to_date = leaderboard&.to_date

      # 获取所有启用的积分规则查询
      queries = DiscourseGamification::GamificationScore.enabled_scorables.map { "( #{_1.query} )" }.join(" UNION ALL ")

      # 构建 SQL 参数
      sql_params = { since: since_date, user_id: user_id }
      sql_params[:to] = to_date if to_date

      # 构建日期过滤条件（安全的方式）
      date_where_clause = "date >= :since"
      date_where_clause += " AND date <= :to" if to_date

      # 只重新计算该用户的积分
      sql = <<~SQL
        -- 删除该用户在指定时间范围内的所有积分记录
        DELETE FROM gamification_scores
        WHERE user_id = :user_id AND #{date_where_clause};

        -- 重新计算并插入该用户的积分
        INSERT INTO gamification_scores (user_id, date, score)
        SELECT user_id, date, SUM(points) AS score
        FROM (
          #{queries}
          UNION ALL
          SELECT user_id, date, SUM(points) AS points
          FROM gamification_score_events
          WHERE user_id = :user_id AND #{date_where_clause}
          GROUP BY 1, 2
        ) AS source
        JOIN users AS u ON u.id = source.user_id
        WHERE source.user_id = :user_id
          AND source.user_id IS NOT NULL
          AND (u.suspended_till IS NULL OR u.suspended_till < CURRENT_TIMESTAMP)
          AND u.active
        GROUP BY 1, 2
        ON CONFLICT (user_id, date) DO UPDATE
        SET score = EXCLUDED.score;
      SQL

      DB.exec(sql, sql_params)

      true
    end
  end
end

