import Foundation

@Observable
final class LessonCatalog {
    private(set) var lessons: [Lesson] = []

    init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "lessons", withExtension: "json") else {
            assertionFailure("lessons.json missing from bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            lessons = try JSONDecoder().decode([Lesson].self, from: data)
        } catch {
            assertionFailure("Failed to decode lessons.json: \(error)")
        }
    }
}
