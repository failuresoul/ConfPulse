import SwiftUI

enum Countdown {
    // Time left as "12d 04h 33m 09s", or "Closed" once the deadline has passed
    static func text(until deadline: Date, now: Date = .now) -> String {
        let seconds = Int(deadline.timeIntervalSince(now))
        guard seconds > 0 else { return "Closed" }
        return String(format: "%dd %02dh %02dm %02ds",
                      seconds / 86_400, seconds % 86_400 / 3_600, seconds % 3_600 / 60, seconds % 60)
    }

    // Red under 7 days, orange under 30 days, green otherwise, gray when closed
    static func color(until deadline: Date, now: Date = .now) -> Color {
        let daysLeft = deadline.timeIntervalSince(now) / 86_400
        if daysLeft <= 0 { return .gray }
        if daysLeft < Double(AppConfig.urgentDays) { return .red }
        if daysLeft < Double(AppConfig.warningDays) { return .orange }
        return .green
    }
}
