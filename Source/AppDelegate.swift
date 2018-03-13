import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.servicesProvider = self

        UserDefaults.standard.register(defaults: [
            LANGUAGE_TO_EXECUTABLE_KEY: LANGUAGE_TO_EXECUTABLE
        ])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func run(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
        run(codeInPasteboard: pboard)
    }

    // TODO Unsure if these can be added dynamically.
    @objc func runAsJavaScript(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
        run(codeInPasteboard: pboard, language: "javascript")
    }

    @objc func runAsPython(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
        run(codeInPasteboard: pboard, language: "python")
    }

    private func run(codeInPasteboard: NSPasteboard, language: String? = nil) {
        if let str = codeInPasteboard.string(forType: NSPasteboard.PasteboardType.string),
           let newNSDocument = try? NSDocumentController.shared.openUntitledDocumentAndDisplay(true),
           let newDocument = newNSDocument as? Document {
            newDocument.codeTextView.string = str
            if let specificLanguage = language {
                newDocument.executeCode(str, language: specificLanguage)
            } else {
                newDocument.runThis(self)
            }
        }
    }
}
