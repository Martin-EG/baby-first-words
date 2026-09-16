import SwiftUI

struct ParentalGateView: View {
    let onPassed: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var a = Int.random(in: 2...8)
    @State private var b = Int.random(in: 2...8)
    @State private var answer = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            PastelPalette.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("🔒 Parents Only")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.pink)
                Text("Solve to continue: \(a) + \(b) = ?")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.pink)
                TextField("Answer", text: $answer)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.pink)
                    .padding(.vertical, 10)
                    .frame(width: 140)
                    .background(RoundedRectangle(cornerRadius: 18).fill(.white))
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.pink.opacity(0.4), lineWidth: 2))
                if showError {
                    Text("Try again").foregroundStyle(.red).fontDesign(.rounded)
                }
                HStack(spacing: 16) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .buttonStyle(.bordered)
                    Button("Continue") { verify() }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                }
                .fontDesign(.rounded)
            }
            .padding(32)
        }
    }

    private func verify() {
        if Int(answer) == a + b {
            onPassed()
        } else {
            showError = true
            a = Int.random(in: 2...8)
            b = Int.random(in: 2...8)
            answer = ""
        }
    }
}
