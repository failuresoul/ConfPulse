import SwiftUI

struct PulseRing: View {
    let deadline: Date
    @State private var isPulsing = false

    // Share of the countdown window still left: 1 = far away, 0 = now or closed
    private var progress: Double {
        let window = AppConfig.countdownWindowDays * 86_400
        return min(1, max(0, deadline.timeIntervalSinceNow / window))
    }

    // Whole days left, never below zero
    private var daysLeft: Int {
        max(0, Int(deadline.timeIntervalSinceNow / 86_400))
    }

    // True while the deadline is open but less than urgentDays away
    private var isUrgent: Bool {
        deadline > .now && daysLeft < AppConfig.urgentDays
    }

    var body: some View {
        let color = Countdown.color(until: deadline)
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text(deadline > .now ? "\(daysLeft)" : "–")
                    .font(.headline.monospacedDigit())
                Text("days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 56, height: 56)
        .scaleEffect(isPulsing ? 1.08 : 1)
        .animation(isUrgent ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                   value: isPulsing)
        .onAppear { isPulsing = isUrgent }
    }
}

#Preview {
    HStack(spacing: 20) {
        PulseRing(deadline: .now.addingTimeInterval(3 * 86_400))
        PulseRing(deadline: .now.addingTimeInterval(20 * 86_400))
        PulseRing(deadline: .now.addingTimeInterval(80 * 86_400))
        PulseRing(deadline: .now.addingTimeInterval(-86_400))
    }
}
