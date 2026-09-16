import SwiftUI

struct ManageFamilyView: View {
    @Environment(FamilyStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                PastelPalette.backgroundGradient.ignoresSafeArea()
                List {
                    ForEach(store.members) { member in
                        HStack(spacing: 14) {
                            AsyncFilePhoto(url: store.photoURL(for: member))
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            Text(member.name).font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets { store.deleteMember(store.members[index]) }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .fontDesign(.rounded)
            .navigationTitle("Mi Familia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }.tint(.pink)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showEditor = true
                    } label: {
                        Label("Agregar", systemImage: "plus.circle.fill")
                    }
                    .tint(.pink)
                }
            }
            .sheet(isPresented: $showEditor) {
                FamilyMemberEditorView()
            }
            .overlay {
                if store.members.isEmpty {
                    ContentUnavailableView(
                        "Aún no hay familiares",
                        systemImage: "person.2.circle",
                        description: Text("Toca “Agregar” para subir la primera foto y voz.")
                    )
                }
            }
        }
    }
}

/// Loads an image from an arbitrary file URL — the asset catalog only
/// knows about bundled images, not parent-added photos on disk.
struct AsyncFilePhoto: View {
    let url: URL

    var body: some View {
        if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            Circle().fill(Color.secondary.opacity(0.2))
        }
    }
}
