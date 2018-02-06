import Cocoa

enum DocumentStatus {
    case languageId
    case running
    case dormant
}

struct DocumentState {
    let status: DocumentStatus
    let language: String
}

class Document: NSDocument {

    static let languageIdService = LanguageIdentificationService()

    @IBOutlet weak var codeTextView: NSTextView!
    @IBOutlet weak var languageLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var runButton: NSButton!

    var state: DocumentState {
        didSet {
            self.stateChanged()
        }
    }

    override init() {
        state = DocumentState(status: .dormant, language: "(unknown)")
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override var windowNibName: NSNib.Name? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return NSNib.Name("Document")
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    @IBAction func runThis(_ sender: Any) {
        let code = codeTextView.string

        state = DocumentState(status: .languageId, language: "(unknown)")
        Document.languageIdService.id().request(.post,
            text: encodeCode(code),
            contentType: "application/json"
        ).onSuccess { result in
            if let languageIdResponse: LanguageIDResponse = result.typedContent() {
                self.state = DocumentState(status: .running,
                    language: languageIdResponse.result[0].language.capitalized)
            }
        }.onFailure { _ in
            self.state = DocumentState(status: .dormant, language: "(unable to determine language)")
        }

        // Thank you https://iswift.org/cookbook/execute-a-shell-command
        let process = Process()
        process.launchPath = "/usr/bin/python"
        process.arguments = ["-c", code]

        let pipe = Pipe()
        process.standardOutput = pipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        var result = "(executed, but no output)"
        if let output = String(data: data, encoding: String.Encoding.utf8) {
            result = output
        }

        if let errorOutput = String(data: errorData, encoding: String.Encoding.utf8),
           errorOutput.count > 0 {
            result = "\(result)\n\nErrors reported:\n\(errorOutput)"
        }

        outputTextView.string = result
    }

    private func encodeCode(_ code: String) -> String {
        let jsonEncoder = JSONEncoder()
        do {
            if let arrayString = String(data: try jsonEncoder.encode([code]), encoding: .utf8) {
                return arrayString.replacingOccurrences(of: "^\\[|\\]$", with: "", options: .regularExpression)
            } else {
                return ""
            }
        } catch {
            return ""
        }
    }

    private func stateChanged() {
        switch state.status {
            case .dormant:
                progressIndicator.stopAnimation(self)
                self.languageLabel.stringValue = state.language
                runButton.isEnabled = true
            case .languageId:
                progressIndicator.startAnimation(self)
                self.languageLabel.stringValue = "Determining language…"
                runButton.isEnabled = false
            case .running:
                progressIndicator.startAnimation(self)
                self.languageLabel.stringValue = "Run as: \(state.language)"
                runButton.isEnabled = false
        }
    }
}
