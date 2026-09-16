import SwiftUI

@main
struct BabyFirstWordsApp: App {
    @State private var catalog = LessonCatalog()
    @State private var settings = AppSettings()
    @State private var audioPlayer = AudioPlayer()
    @State private var familyStore = FamilyStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(catalog)
                .environment(settings)
                .environment(audioPlayer)
                .environment(familyStore)
                .preferredColorScheme(.light)
        }
    }
}
