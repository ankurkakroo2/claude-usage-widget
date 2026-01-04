import SwiftUI

@main
struct ClaudeUsageWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - this is a menu bar only app
        NSApp.setActivationPolicy(.accessory)

        // Initialize menu bar controller
        menuBarController = MenuBarController()

        print("🚀 Claude Usage Widget started")
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("👋 Claude Usage Widget stopped")
    }
}
