import Foundation

struct LanguageIDMetadata: Codable, Equatable {
    let content_type: String
    let duration: Double
}

struct LanguageIDProbability: Codable, Equatable {
    let language: String
    let probability: Double
}

struct LanguageIDResponse: Decodable, Equatable {
    let result: [LanguageIDProbability]
    let metadata: LanguageIDMetadata

    static func ==(lhs: LanguageIDResponse, rhs: LanguageIDResponse) -> Bool {
        return lhs.result == rhs.result && lhs.metadata == rhs.metadata
    }

    enum CodingKeys: String, CodingKey {
        case result
        case metadata
    }

    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        var result = try response.nestedUnkeyedContainer(forKey: CodingKeys.result)
        var decodedResult = [LanguageIDProbability]()
        for _ in 0..<result.count! {
            var probabilityContainer = try result.nestedUnkeyedContainer()
            let language = try probabilityContainer.decode(String.self)
            let probability = try probabilityContainer.decode(Double.self)
            decodedResult.append(LanguageIDProbability(language: language, probability: probability))
        }

        self.result = decodedResult
        self.metadata = try response.decode(LanguageIDMetadata.self, forKey: .metadata)
    }
}
