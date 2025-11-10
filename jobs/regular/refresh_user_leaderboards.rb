# frozen_string_literal: true

module Jobs
  # 刷新用户相关的所有 leaderboard positions（异步执行）
  class RefreshUserLeaderboards < ::Jobs::Base
    def execute(args)
      user_id = args[:user_id]
      raise Discourse::InvalidParameters.new(:user_id) if user_id.blank?

      # 刷新所有 leaderboard positions，以便 user.gamification_score 能获取到最新值
      if defined?(DiscourseGamification::GamificationLeaderboard)
        DiscourseGamification::GamificationLeaderboard.all.each do |leaderboard|
          Jobs.enqueue(
            Jobs::RefreshLeaderboardPositions,
            leaderboard_id: leaderboard.id,
          )
        end
      end
    end
  end
end

