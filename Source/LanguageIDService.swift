import Siesta

class LanguageIdentificationService {
    private let service = Service(
        baseURL: "https://api.algorithmia.com/v1/algo/PetiteProgrammer/ProgrammingLanguageIdentification/0.1.3",
        standardTransformers: [.text, .image])

    init() {
        // Bare-bones logging of which network calls Siesta makes:
        SiestaLog.Category.enabled = [.network]

        // For more info about how Siesta decides whether to make a network call,
        // and which state updates it broadcasts to the app:
        //SiestaLog.Category.enabled = SiestaLog.Category.common
        // For the gory details of what Siesta’s up to:
        //SiestaLog.Category.enabled = SiestaLog.Category.all
        // To dump all requests and responses:
        // (Warning: may cause Xcode console overheating)
        //SiestaLog.Category.enabled = SiestaLog.Category.all

        service.configure(whenURLMatches: {self.service.baseURL!.host == $0.host}) {
            $0.headers["Authorization"] = "Simple \(LANGUAGE_ID_TOKEN)"
        }

        let jsonDecoder = JSONDecoder()
        service.configureTransformer("/") {
            try jsonDecoder.decode(LanguageIDResponse.self, from: $0.content)
        }
    }

    func id() -> Resource {
        return service.resource("/")
    }
}
