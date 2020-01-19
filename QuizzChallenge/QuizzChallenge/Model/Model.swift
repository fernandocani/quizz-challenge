import Foundation

// MARK: - Quizz
struct Quizz: Codable {
    var question: String?
    var answer: [String]?

    enum CodingKeys: String, CodingKey {
        case question = "question"
        case answer = "answer"
    }
}
