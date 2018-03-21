import Cocoa
import WebKit

enum DocumentStatus {
    case languageId
    case running
    case dormant
}

struct DocumentState {
    let status: DocumentStatus
    let language: String
}

class Document: NSDocument, WKNavigationDelegate {

    static let languageIdService = LanguageIdentificationService()

    @IBOutlet weak var codeTextView: NSTextView!
    @IBOutlet weak var languageLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var webView: WKWebView!

    var state: DocumentState {
        didSet {
            self.stateChanged()
        }
    }

    // Temporary holder to keep the executor from going out of scope.
    var webKitExecutor: WebKitExecutor?

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
                self.executeCode(code, language: languageIdResponse.result[0].language)
            }
        }.onFailure { _ in
            self.state = DocumentState(status: .dormant, language: "(unable to determine language)")
        }
    }

    // TODO Is it possible to make these language-specific actions dynamic, based on the available language mappings?
    @IBAction func runJavaScript(_ sender: Any) {
        executeCode(codeTextView.string, language: "javascript")
    }

    @IBAction func runPerl(_ sender: Any) {
        executeCode(codeTextView.string, language: "perl")
    }

    @IBAction func runPython(_ sender: Any) {
        executeCode(codeTextView.string, language: "python")
    }

    @IBAction func runRuby(_ sender: Any) {
        executeCode(codeTextView.string, language: "ruby")
    }

    @IBAction func runSwift(_ sender: Any) {
        executeCode(codeTextView.string, language: "swift")
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

    func executeCode(_ code: String, language: String) {
        state = DocumentState(status: .running, language: language)
        let languageDisplayName = LANGUAGE_TO_DISPLAY[state.language] ?? "(unknown)"
        if language == "javascript" {
            executeWebKitCode(code, language: language, displaying: languageDisplayName)
        } else {
            executeStdIoCode(code, language: language, displaying: languageDisplayName)
        }
    }

    private func executeStdIoCode(_ code: String, language: String, displaying languageDisplayName: String) {
        guard let languageMappings = UserDefaults.standard.dictionary(forKey: LANGUAGE_TO_EXECUTABLE_KEY),
              let executable = languageMappings[language] as? String else {
            state = DocumentState(status: .dormant, language: "(unable to run \(languageDisplayName)")
            return
        }

        displayExecutionResult(Executor(executable: executable).execute(code: code))
    }

    private func executeWebKitCode(_ code: String, language: String, displaying languageDisplayName: String) {
        webKitExecutor = WebKitExecutor(webView: webView)
        webKitExecutor!.execute(code: code) { result in
            self.displayExecutionResult(result)

            // Get rid of the web kit executor when we are done.
            self.webView.navigationDelegate = nil
            self.webView.uiDelegate = nil
            self.webKitExecutor = nil
        }
    }

    private func displayExecutionResult(_ result: ExecutionResult) {
        outputTextView.string = """
            \(result.output.count > 0 ? result.output : "(executed, but no output)")
            \(result.error.count > 0 ? "\n\nErrors reported:\n\(result.error)" : "")
            """

        state = DocumentState(status: .dormant, language: state.language)
    }

    private func stateChanged() {
        let languageDisplayName = LANGUAGE_TO_DISPLAY[state.language] ?? "(unknown)"
        switch state.status {
            case .dormant:
                progressIndicator.stopAnimation(self)
                self.languageLabel.stringValue = languageDisplayName
            case .languageId:
                progressIndicator.startAnimation(self)
                self.languageLabel.stringValue = "Determining language…"
            case .running:
                progressIndicator.startAnimation(self)
                self.languageLabel.stringValue = "Run as: \(languageDisplayName)"
        }
    }
}
