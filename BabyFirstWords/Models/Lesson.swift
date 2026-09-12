import Foundation

struct Lesson: Identifiable, Decodable, Hashable {
    let id: String
    let enName: String
    let esName: String
    let icon: String
    let color: String
    let words: [Word]

    private enum CodingKeys: String, CodingKey {
        case id = "lesson_id"
        case enName = "en_name"
        case esName = "es_name"
        case icon
        case color
        case words
    }

    func name(for language: AppLanguage) -> String {
        switch language {
        case .english: return enName
        case .spanish: return esName
        }
    }
}
