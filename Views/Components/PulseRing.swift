import SwiftUI

struct PulseRing: View {
    let progress: Double   // 0 = nothing done, 1 = everything done
    @State private var isPulsing = false

    // True when every task is done
    private var isComplete: Bool { progress >= 1 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.pulse.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(isComplete ? Color.green : Theme.pulse,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            Text("\(Int((progress * 100).rounded()))%")
                .font(.headline.monospacedDigit())
        }
        .frame(width: 72, height: 72)
        .scaleEffect(isPulsing ? 1.08 : 1)
        .animation(isPulsing ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true) : .default,
                   value: isPulsing)
        .onAppear { isPulsing = isComplete }
        .onChange(of: isComplete) { _, complete in isPulsing = complete }
    }
}

#Preview {
    HStack(spacing: 24) {
        PulseRing(progress: 0)
        PulseRing(progress: 0.4)
        PulseRing(progress: 1)
    }
}
