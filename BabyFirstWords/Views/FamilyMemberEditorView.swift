import SwiftUI
import PhotosUI

struct FamilyMemberEditorView: View {
    @Environment(FamilyStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var recorder = AudioRecorder()
    @State private var previewPlayer = AudioPlayer()
    @State private var micDenied = false
    @State private var saveError = false
    @State private var isPreparingToRecord = false

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && photoData != nil
            && recorder.recordedURL != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PastelPalette.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        photoSection
                        nameField
                        audioSection
                    }
                    .padding(24)
                }
            }
            .fontDesign(.rounded)
            .navigationTitle("Nuevo familiar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(!canSave)
                        .tint(.pink)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    photoData = image.jpegData(compressionQuality: 0.85)
                }
                .ignoresSafeArea()
            }
            .alert("Necesitamos el micrófono", isPresented: $micDenied) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Activa el acceso al micrófono en Ajustes para grabar tu voz.")
            }
            .alert("No se pudo guardar", isPresented: $saveError) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.white).frame(width: 160, height: 160)
                if let photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(.pink.opacity(0.6))
                }
            }
            .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 6)

            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Galería", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            photoData = data
                        }
                    }
                }

                Button {
                    showCamera = true
                } label: {
                    Label("Cámara", systemImage: "camera.fill")
                }
                .buttonStyle(.bordered)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
            }
            .tint(.pink)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nombre").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary)
            TextField("Ej. Abuela Rosa", text: $name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        }
        .frame(maxWidth: .infinity)
    }

    private var audioSection: some View {
        VStack(spacing: 10) {
            Text("Graba tu voz diciendo su nombre").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary)

            Button {
                toggleRecording()
            } label: {
                Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(isPreparingToRecord ? .gray : (recorder.isRecording ? .red : .pink))
            }
            .disabled(isPreparingToRecord)

            if recorder.recordedURL != nil && !recorder.isRecording {
                Button {
                    previewPlayer.play(fileAt: recorder.recordedURL!, volume: 1.0)
                } label: {
                    Label("Escuchar", systemImage: "play.fill")
                }
                .buttonStyle(.bordered)
                .tint(.pink)
            }
        }
    }

    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
            return
        }
        isPreparingToRecord = true
        recorder.requestPermission { granted in
            isPreparingToRecord = false
            if granted {
                recorder.startRecording()
            } else {
                micDenied = true
            }
        }
    }

    private func save() {
        guard let photoData, let audioURL = recorder.recordedURL else { return }
        do {
            try store.addMember(name: name.trimmingCharacters(in: .whitespaces), photoData: photoData, recordedAudioURL: audioURL)
            dismiss()
        } catch {
            saveError = true
        }
    }
}
