import SwiftUI

struct PulseRing: View {
    let countdown: Countdown
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(countdown.color.opacity(0.2), lineWidth: 6)
            Circle()
                .trim(from: 0, to: countdown.progress)
                .stroke(countdown.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text(countdown.isPast ? "–" : "\(countdown.days)")
                    .font(.headline.monospacedDigit())
                Text("days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 56, height: 56)
        .scaleEffect(isPulsing ? 1.08 : 1)
        .animation(countdown.isUrgent ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                   value: isPulsing)
        .onAppear { isPulsing = countdown.isUrgent }
    }
}

#Preview {
    HStack(spacing: 20) {
        PulseRing(countdown: Countdown(to: .now.addingTimeInterval(3 * 86_400)))
        PulseRing(countdown: Countdown(to: .now.addingTimeInterval(20 * 86_400)))
        PulseRing(countdown: Countdown(to: .now.addingTimeInterval(80 * 86_400)))
        PulseRing(countdown: Countdown(to: .now.addingTimeInterval(-86_400)))
    }
}
