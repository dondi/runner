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
    let result: [[Any]]
    let metadata: LanguageIDMetadata

    static func ==(lhs: LanguageIDResponse, rhs: LanguageIDResponse) -> Bool {
        return lhs.metadata == rhs.metadata
    }

    enum CodingKeys: String, CodingKey {
        case result
        case metadata
    }

    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        var result = try response.nestedUnkeyedContainer(forKey: CodingKeys.result)
        var decodedResult = [[Any]]()
        for _ in 0..<result.count! {
            var probability = try result.nestedUnkeyedContainer()
            var decodedProbability = [Any]()
            decodedProbability.append(try probability.decode(String.self))
            decodedProbability.append(try probability.decode(Double.self))
            decodedResult.append(decodedProbability)
        }

        self.result = decodedResult
        self.metadata = try response.decode(LanguageIDMetadata.self, forKey: .metadata)
    }
}
