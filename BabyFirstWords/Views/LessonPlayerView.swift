import SwiftUI

struct LessonPlayerView: View {
    let lesson: Lesson

    @Environment(AppSettings.self) private var settings
    @Environment(AudioPlayer.self) private var audioPlayer
    @State private var index = 0

    private var word: Word { lesson.words[index] }
    private var tileColor: Color { PastelPalette.color(named: lesson.color) }

    var body: some View {
        ZStack {
            PastelPalette.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    ForEach(lesson.words.indices, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(i == index ? tileColor : Color.secondary.opacity(0.25))
                            .scaleEffect(i == index ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3), value: index)
                    }
                }
                .padding(.top, 12)

                Spacer()

                Image(word.id)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .strokeBorder(.white, lineWidth: 6)
                    )
                    .shadow(color: tileColor.opacity(0.6), radius: 14, x: 0, y: 10)
                    .padding(.horizontal, 24)
                    .contentShape(Rectangle())
                    .onTapGesture { playCurrentWord() }
                    .gesture(
                        DragGesture(minimumDistance: 40)
                            .onEnded { value in
                                guard !audioPlayer.isPlaying else { return }
                                if value.translation.width < 0 {
                                    goTo(index + 1)
                                } else if value.translation.width > 0 {
                                    goTo(index - 1)
                                }
                            }
                    )

                Text(word.text(for: settings.language))
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(tileColor)
                    .padding(.top, 8)
                    .shadow(color: .white, radius: 0, x: 2, y: 2)

                Spacer()

                HStack(spacing: 36) {
                    RoundButton(systemName: "arrow.left.circle.fill", color: tileColor, disabled: audioPlayer.isPlaying) {
                        goTo(index - 1)
                    }
                    RoundButton(systemName: "speaker.wave.3.fill", color: .pink, big: true, disabled: audioPlayer.isPlaying) {
                        playCurrentWord()
                    }
                    RoundButton(systemName: "arrow.right.circle.fill", color: tileColor, disabled: audioPlayer.isPlaying) {
                        goTo(index + 1)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .fontDesign(.rounded)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle(lesson.name(for: settings.language))
        .onAppear {
            settings.markLessonOpened(lesson.id)
            playCurrentWord()
        }
        .onChange(of: settings.language) {
            playCurrentWord()
        }
    }

    private func goTo(_ newIndex: Int) {
        guard !audioPlayer.isPlaying else { return }
        let count = lesson.words.count
        index = ((newIndex % count) + count) % count
        playCurrentWord()
    }

    private func playCurrentWord() {
        audioPlayer.play(word: word, language: settings.language, volume: settings.volume)
    }
}

private struct RoundButton: View {
    let systemName: String
    let color: Color
    var big: Bool = false
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: big ? 34 : 30))
                .foregroundStyle(.white)
                .frame(width: big ? 84 : 68, height: big ? 84 : 68)
                .background(Circle().fill(color.gradient))
                .shadow(color: color.opacity(0.6), radius: 8, x: 0, y: 5)
        }
        .disabled(disabled)
        .opacity(disabled ? 0.45 : 1.0)
    }
}
