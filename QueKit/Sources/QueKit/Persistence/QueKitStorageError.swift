import Foundation

public enum QueKitStorageError: LocalizedError, Equatable {
    case iCloudContainerUnavailable(identifier: String)

    public var errorDescription: String? {
        switch self {
        case let .iCloudContainerUnavailable(identifier):
            "The iCloud container \(identifier) is unavailable. Confirm it is in the host app's entitlements and iCloud Drive is enabled."
        }
    }
}
