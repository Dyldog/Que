import ProjectDescription

let sharedSettings: SettingsDictionary = [
    "SWIFT_VERSION": "5.0",
    "CODE_SIGN_STYLE": "Automatic",
    "DEVELOPMENT_TEAM": "6CW3378X23",
    "CODE_SIGN_IDENTITY": "Apple Development",
]

let qyayICloudContainer = "iCloud.com.qyay.QYay"

let project = Project(
    name: "Que",
    packages: [
        .local(path: "../QYayKit"),
    ],
    settings: .settings(base: sharedSettings),
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
                "NSUbiquitousContainers": [
                    qyayICloudContainer: [
                        "NSUbiquitousContainerName": "QYay",
                        "NSUbiquitousContainerIsDocumentScopePublic": true,
                    ],
                ],
            ]),
            sources: ["Que/Sources/**"],
            resources: ["Que/Resources/**"],
            entitlements: .dictionary([
                "com.apple.developer.icloud-container-identifiers": .array([.string(qyayICloudContainer)]),
                "com.apple.developer.icloud-services": .array([.string("CloudDocuments")]),
                "com.apple.developer.ubiquity-container-identifiers": .array([.string(qyayICloudContainer)]),
            ]),
            dependencies: [
                .package(product: "QYayKit"),
            ]
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
