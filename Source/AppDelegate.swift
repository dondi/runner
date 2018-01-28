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
        guard let str = pboard.string(forType: NSPasteboard.PasteboardType.string) else {
            // TODO End silently or complain about the wrong data before returning?
            return
        }

        // Thank you https://iswift.org/cookbook/execute-a-shell-command
        let process = Process()
        process.launchPath = "/usr/bin/python"
        process.arguments = ["-c", str]

        let pipe = Pipe()
        process.standardOutput = pipe

        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print("Runner output:\n\(output)")
        } else {
            print("Runner: No output")
        }
    }
}
