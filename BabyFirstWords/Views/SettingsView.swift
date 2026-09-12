import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(LessonCatalog.self) private var catalog
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            ZStack {
                PastelPalette.backgroundGradient.ignoresSafeArea()
                Form {
                    Section("🌐 Language") {
                        Picker("Language", selection: $settings.language) {
                            ForEach(AppLanguage.allCases, id: \.self) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("🔊 Volume") {
                        Slider(value: $settings.volume, in: 0...1)
                            .tint(.pink)
                    }

                    Section("⭐ Progress") {
                        ForEach(catalog.lessons) { lesson in
                            HStack {
                                Text(lesson.name(for: settings.language))
                                Spacer()
                                if settings.openedLessonIDs.contains(lesson.id) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                } else {
                                    Image(systemName: "star")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .fontDesign(.rounded)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .tint(.pink)
                }
            }
        }
    }
}
