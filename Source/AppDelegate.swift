import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.servicesProvider = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func run(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
        if let str = pboard.string(forType: NSPasteboard.PasteboardType.string) {
            print("Submitted to service: \(str)")
        }
    }
}
