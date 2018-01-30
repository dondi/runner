import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var console: NSTextView!

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
        var result = "(executed, but no output)"
        if let output = String(data: data, encoding: String.Encoding.utf8) {
            result = output
        }

        console.string = "\(console.string)\n-----\n\nCode:\n\n\(str)\n\n-----\n\n\(result)"
    }
}
