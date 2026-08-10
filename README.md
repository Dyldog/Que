# QueKit

Shared vocabulary-list logic for Que, Spangle, and other Apple-platform apps.

QueKit provides:

- `Word`, `Language`, and `WordList` models.
- Que's built-in and personal bundled Spanish lists through `QueListLibrary`.
- User-list CRUD in a shared iCloud Drive container through `ICloudWordListStore`.
- One-time migration from Que's former `UserDefaults` storage.
- On-device prompt list generation through `FoundationModelsWordListGenerator`.

## Host app setup

Add the package and enable iCloud Documents for `iCloud.com.dylanelliott.QueKit` in every host app. The host app—not a Swift package—owns the entitlement. Add the same container under `NSUbiquitousContainers` in Info.plist.

User-created lists are individual JSON documents under `Documents/QueKit/Lists` so apps can read and update the same collection.
