import PackageDescription

let package = Package(
    name: "Tictoc",
    dependencies: [
        .Package(url: "../GCD", majorVersion:1, minor: 1)
    ]
)
