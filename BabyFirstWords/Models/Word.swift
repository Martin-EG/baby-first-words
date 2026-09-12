import Foundation

struct Word: Identifiable, Decodable, Hashable {
    let id: String
    let enText: String
    let esText: String

    private enum CodingKeys: String, CodingKey {
        case id = "word_id"
        case enText = "en_text"
        case esText = "es_text"
    }

    func text(for language: AppLanguage) -> String {
        switch language {
        case .english: return enText
        case .spanish: return esText
        }
    }

    func audioFileName(for language: AppLanguage) -> String {
        "\(id).m4a"
    }
}
