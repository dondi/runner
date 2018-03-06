import WebKit

let PAGE_CONTEXT = """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <title>JavaScript Runner</title>
      </head>
      <body>
        <script>
          // We channel console logs through alert so that the UI delegate picks them up.
          const routeToAlert = (...arguments) => window.alert.call(window, arguments.map(JSON.stringify))
          window.console.log = routeToAlert
          window.console.debug = routeToAlert
          window.console.info = routeToAlert
          window.console.warn = routeToAlert
          window.console.error = routeToAlert
        </script>
      </body>
    </html>
    """

// Special case for JavaScript execution.
class WebKitExecutor: NSObject, WKNavigationDelegate, WKUIDelegate {

    let webView: WKWebView
    var output: String = ""

    var code: String?
    var callback: ((ExecutionResult) -> Void)?

    init(webView: WKWebView) {
        self.webView = webView
        super.init()

        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
    }

    func execute(code: String, callback: @escaping (ExecutionResult) -> Void) {
        self.code = code
        self.callback = callback
        output = ""

        webView.loadHTMLString(PAGE_CONTEXT, baseURL: nil)
        // From this point, we wait for notification.
    }

    func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
        guard let code = self.code,
              let callback = self.callback else {
            // If we get here, something's out of order. We return, thus ensuring no callback and presumably the user
            // or dev then perceives that something is wrong.
            return
        }

        webView.evaluateJavaScript(code) { possibleResult, possibleError in
            var errorOutput = ""

            if let result = possibleResult {
                self.output = "\(self.output)\n\nReturn value:\n\(result)"
            }

            if let error = possibleError {
                errorOutput = "\(error)"
            }

            callback(ExecutionResult(output: self.output, error: errorOutput))
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // Treat window.alert like a console message.
        output = "\(output)\n\(message)"
        completionHandler()
    }
}
