import ProjectDescription

let project = Project(
    name: "Que",
    targets: [
        .target(
            name: "Que",
            destinations: .iOS,
            product: .app,
            bundleId: "com.dylanelliott.Que",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                ],
            ]),
            sources: ["Que/Sources/**"],
            resources: ["Que/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "QueTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.dylanelliott.QueTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Que/Tests/**"],
            dependencies: [.target(name: "Que")]
        ),
    ]
)
