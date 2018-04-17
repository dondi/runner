import Foundation

class StdioExecutor {

    let executable: String

    init(executable: String) {
        self.executable = executable
    }

    func execute(code: String) -> ExecutionResult {
        // Thank you https://iswift.org/cookbook/execute-a-shell-command
        let process = Process()
        process.launchPath = executable

        let inputPipe = Pipe()
        process.standardInput = inputPipe

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        process.launch()

        inputPipe.fileHandleForWriting.write(code.data(using: .utf8)!)
        inputPipe.fileHandleForWriting.closeFile()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        return ExecutionResult(
            output: String(data: outputData, encoding: .utf8) ?? "",
            error: String(data: errorData, encoding: .utf8) ?? "")
    }
}
