import Foundation

// SharedDefaults provides a shared UserDefaults suite accessible by both the main app
// and the PuffwiseWidget extension.
//
// **Why App Groups?**
// iOS sandboxes each app and extension in its own container. A widget extension is a
// separate process that cannot read the main app's UserDefaults.standard. An App Group
// (configured in Signing & Capabilities) creates a shared container that both processes
// can access via the same suite name.
//
// **How to set up the App Group:**
// Both targets (Puffwise + PuffwiseWidget) must have the App Group
// "group.com.puffwise.app" added under Signing & Capabilities in Xcode.
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.puffwise.app")!
}
