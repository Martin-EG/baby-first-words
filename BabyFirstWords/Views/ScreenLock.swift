import SwiftUI
import UIKit

/// A Disney+-style screen lock: tap once to lock (freezes every tap/swipe on
/// the screen below it), then hold the same button ~2s to unlock — long
/// enough that a toddler's random taps can't undo it, short enough for a
/// parent to do on purpose.
struct LockToggleButton: View {
    @Binding var isLocked: Bool
    @State private var isHolding = false

    private static let holdDuration: TimeInterval = 2.0

    var body: some View {
        Group {
            if isLocked {
                unlockControl
            } else {
                Button {
                    isLocked = true
                } label: {
                    icon
                }
            }
        }
    }

    private var unlockControl: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: isHolding ? 1 : 0)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 38, height: 38)
                .animation(isHolding ? .linear(duration: Self.holdDuration) : .linear(duration: 0.15), value: isHolding)
            icon
        }
        .contentShape(Circle())
        .onLongPressGesture(minimumDuration: Self.holdDuration, maximumDistance: 50) {
            isLocked = false
            isHolding = false
        } onPressingChanged: { pressing in
            isHolding = pressing
        }
    }

    private var icon: some View {
        Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .padding(10)
            .background(Circle().fill(Color.pink.opacity(0.85)))
    }
}

/// Dims the screen and swallows every tap/swipe/drag underneath it while locked.
struct LockScrim: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.12).ignoresSafeArea()
            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 30))
                Text("Pantalla bloqueada")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("Mantén presionado el candado para desbloquear")
                    .font(.system(size: 13, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.35)))
        }
        .contentShape(Rectangle())
        .onTapGesture {}
        .gesture(DragGesture(minimumDistance: 0))
        .transition(.opacity)
    }
}

/// Disables the interactive edge-swipe-back gesture while the screen is
/// locked — hiding the back button alone doesn't stop that gesture.
struct DisableSwipeBack: UIViewControllerRepresentable {
    var isDisabled: Bool

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = !isDisabled
        }
    }
}
