import SwiftUI

struct HomeView: View {
    @Environment(LessonCatalog.self) private var catalog
    @Environment(AppSettings.self) private var settings
    @State private var showGate = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                PastelPalette.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("🌟 Baby First Words 🌟")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(.pink)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)

                        ForEach(catalog.lessons) { lesson in
                            NavigationLink {
                                LessonPlayerView(lesson: lesson)
                            } label: {
                                LessonTile(lesson: lesson, language: settings.language)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showGate = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Circle().fill(Color.pink.opacity(0.8)))
                    }
                }
            }
            .sheet(isPresented: $showGate) {
                ParentalGateView {
                    showGate = false
                    showSettings = true
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .fontDesign(.rounded)
    }
}

private struct LessonTile: View {
    let lesson: Lesson
    let language: AppLanguage

    private var tileColor: Color { PastelPalette.color(named: lesson.color) }

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.55))
                    .frame(width: 76, height: 76)
                Image(systemName: lesson.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            Text(lesson.name(for: language))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(tileColor.gradient)
        )
        .shadow(color: tileColor.opacity(0.5), radius: 8, x: 0, y: 6)
    }
}
