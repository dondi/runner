import Foundation

let LANGUAGE_TO_EXECUTABLE_KEY = "languageToExecutable"

let LANGUAGE_TO_EXECUTABLE: [String:String] = [
    "java": "/usr/bin/java", // Not really applicable due to compilation but just in case.
    "javascript": "/usr/local/bin/node",
    "perl": "/usr/bin/perl",
    "python": "/usr/bin/python",
    "ruby": "/usr/bin/irb",
    "swift": "/usr/bin/swift"
]

let LANGUAGE_TO_DISPLAY: [String:String] = [
    "java": "Java",
    "javascript": "JavaScript",
    "perl": "Perl",
    "python": "Python",
    "ruby": "Ruby",
    "swift": "Swift"
]
