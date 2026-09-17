import Foundation

/// Persists the parent-authored "Mi Familia" cards: a name, a photo, and a
/// voice recording per family member. Unlike the bundled lesson content,
/// this lives in the app's Documents directory so it survives app updates
/// and is unique to this device/child.
@Observable
final class FamilyStore {
    private(set) var members: [FamilyMember] = []

    private let fileManager = FileManager.default
    private let metadataURL: URL
    let mediaDirectory: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        mediaDirectory = documents.appendingPathComponent("FamilyMedia", isDirectory: true)
        metadataURL = documents.appendingPathComponent("family.json")
        try? fileManager.createDirectory(at: mediaDirectory, withIntermediateDirectories: true)
        load()
    }

    func photoURL(for member: FamilyMember) -> URL {
        mediaDirectory.appendingPathComponent(member.photoFileName)
    }

    func audioURL(for member: FamilyMember) -> URL {
        mediaDirectory.appendingPathComponent(member.audioFileName)
    }

    /// Copies the given photo/recording into permanent storage and adds a new member.
    func addMember(name: String, photoData: Data, recordedAudioURL: URL) throws {
        let id = UUID()
        let photoFileName = "\(id).jpg"
        let audioFileName = "\(id).m4a"
        try writeMedia(photoData: photoData, audioSourceURL: recordedAudioURL, photoFileName: photoFileName, audioFileName: audioFileName)

        let member = FamilyMember(id: id, name: name, photoFileName: photoFileName, audioFileName: audioFileName)
        members.append(member)
        save()
    }

    /// Updates an existing member in place (same id, same file names) so
    /// edits never orphan old photo/audio files. `audioSourceURL` may be the
    /// member's own existing recording (kept as-is) or a freshly recorded one.
    func updateMember(_ member: FamilyMember, name: String, photoData: Data, audioSourceURL: URL) throws {
        try writeMedia(photoData: photoData, audioSourceURL: audioSourceURL, photoFileName: member.photoFileName, audioFileName: member.audioFileName)
        guard let index = members.firstIndex(where: { $0.id == member.id }) else { return }
        members[index].name = name
        save()
    }

    private func writeMedia(photoData: Data, audioSourceURL: URL, photoFileName: String, audioFileName: String) throws {
        try photoData.write(to: mediaDirectory.appendingPathComponent(photoFileName), options: .atomic)

        let destinationAudioURL = mediaDirectory.appendingPathComponent(audioFileName)
        guard audioSourceURL.standardizedFileURL != destinationAudioURL.standardizedFileURL else { return }
        if fileManager.fileExists(atPath: destinationAudioURL.path) {
            try fileManager.removeItem(at: destinationAudioURL)
        }
        try fileManager.copyItem(at: audioSourceURL, to: destinationAudioURL)
    }

    func deleteMember(_ member: FamilyMember) {
        try? fileManager.removeItem(at: photoURL(for: member))
        try? fileManager.removeItem(at: audioURL(for: member))
        members.removeAll { $0.id == member.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: metadataURL) else { return }
        members = (try? JSONDecoder().decode([FamilyMember].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(members) else { return }
        try? data.write(to: metadataURL)
    }
}
