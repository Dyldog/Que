import ProjectDescription

let project = Project(
    name: "Que",
    settings: .settings(base: ["SWIFT_VERSION": "5.0"]),
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
                "NSMicrophoneUsageDescription":
                    "Que listens to your spoken answer so it can check it for you.",
                "NSSpeechRecognitionUsageDescription":
                    "Que uses speech recognition to tell whether you said the right word.",
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
