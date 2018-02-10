import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.servicesProvider = self

        UserDefaults.standard.register(defaults: [
            "languageMappings": LANGUAGE_TO_EXECUTABLE
        ])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func run(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
        if let str = pboard.string(forType: NSPasteboard.PasteboardType.string) {
            if let newNSDocument = try? NSDocumentController.shared.openUntitledDocumentAndDisplay(true),
               let newDocument = newNSDocument as? Document {
                newDocument.codeTextView.string = str
                newDocument.runThis(self)
            }
        }
    }
}
