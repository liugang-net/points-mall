export default function () {
    this.route("points-mall", { path: "/points-mall" }, function () {
        this.route("index", { path: "/" });
        this.route("products", { path: "/products" });
    });
}

