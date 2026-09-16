import SwiftUI

struct FamilyLessonView: View {
    @Environment(FamilyStore.self) private var store
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(AppSettings.self) private var settings
    @State private var index = 0
    @State private var showGate = false
    @State private var showManage = false

    private var member: FamilyMember? {
        store.members.indices.contains(index) ? store.members[index] : nil
    }

    var body: some View {
        ZStack {
            PastelPalette.backgroundGradient.ignoresSafeArea()

            if store.members.isEmpty {
                emptyState
            } else {
                browsingContent
            }
        }
        .fontDesign(.rounded)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("Mi Familia")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showGate = true } label: {
                    Image(systemName: "pencil.circle.fill").font(.title2).foregroundStyle(.pink)
                }
            }
        }
        .sheet(isPresented: $showGate) {
            ParentalGateView {
                showGate = false
                showManage = true
            }
        }
        .sheet(isPresented: $showManage) {
            ManageFamilyView()
        }
        .onChange(of: store.members.count) {
            if index >= store.members.count { index = max(0, store.members.count - 1) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.pink.opacity(0.5))
            Text("Agrega a tu familia")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
            Text("Toca el lápiz arriba para subir una foto y grabar tu voz.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    @ViewBuilder
    private var browsingContent: some View {
        if let member {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    ForEach(store.members.indices, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(i == index ? Color.pink : Color.secondary.opacity(0.25))
                            .scaleEffect(i == index ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3), value: index)
                    }
                }
                .padding(.top, 12)

                Spacer()

                AsyncFilePhoto(url: store.photoURL(for: member))
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .strokeBorder(.white, lineWidth: 6)
                    )
                    .shadow(color: .pink.opacity(0.5), radius: 14, x: 0, y: 10)
                    .padding(.horizontal, 24)
                    .contentShape(Rectangle())
                    .onTapGesture { play(member) }
                    .gesture(
                        DragGesture(minimumDistance: 40)
                            .onEnded { value in
                                if value.translation.width < 0 { goTo(index + 1) }
                                else if value.translation.width > 0 { goTo(index - 1) }
                            }
                    )

                Text(member.name)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.pink)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Spacer()

                HStack(spacing: 36) {
                    RoundNavButton(systemName: "arrow.left.circle.fill") { goTo(index - 1) }
                    RoundNavButton(systemName: "speaker.wave.3.fill", big: true) { play(member) }
                    RoundNavButton(systemName: "arrow.right.circle.fill") { goTo(index + 1) }
                }
                .padding(.bottom, 32)
            }
            .onAppear { play(member) }
        }
    }

    private func goTo(_ newIndex: Int) {
        let count = store.members.count
        guard count > 0 else { return }
        index = ((newIndex % count) + count) % count
        if let member { play(member) }
    }

    private func play(_ member: FamilyMember) {
        audioPlayer.play(fileAt: store.audioURL(for: member), volume: settings.volume)
    }
}

private struct RoundNavButton: View {
    let systemName: String
    var big: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: big ? 34 : 30))
                .foregroundStyle(.white)
                .frame(width: big ? 84 : 68, height: big ? 84 : 68)
                .background(Circle().fill(Color.pink.gradient))
                .shadow(color: .pink.opacity(0.6), radius: 8, x: 0, y: 5)
        }
    }
}
