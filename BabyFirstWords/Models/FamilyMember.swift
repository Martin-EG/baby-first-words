import Foundation

struct FamilyMember: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    let photoFileName: String
    let audioFileName: String

    init(id: UUID = UUID(), name: String, photoFileName: String, audioFileName: String) {
        self.id = id
        self.name = name
        self.photoFileName = photoFileName
        self.audioFileName = audioFileName
    }
}
