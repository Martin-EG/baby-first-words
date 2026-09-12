import Foundation

enum AppLanguage: String, CaseIterable {
    case english
    case spanish

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}

@Observable
final class AppSettings {
    private let defaults: UserDefaults

    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }

    var volume: Double {
        didSet { defaults.set(volume, forKey: Keys.volume) }
    }

    private(set) var openedLessonIDs: Set<String> {
        didSet { defaults.set(Array(openedLessonIDs), forKey: Keys.openedLessons) }
    }

    private enum Keys {
        static let language = "settings.language"
        static let volume = "settings.volume"
        static let openedLessons = "settings.openedLessons"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedLanguage = defaults.string(forKey: Keys.language).flatMap(AppLanguage.init(rawValue:))
        self.language = storedLanguage ?? .spanish
        self.volume = defaults.object(forKey: Keys.volume) as? Double ?? 1.0
        self.openedLessonIDs = Set(defaults.stringArray(forKey: Keys.openedLessons) ?? [])
    }

    func markLessonOpened(_ lessonID: String) {
        openedLessonIDs.insert(lessonID)
    }
}
