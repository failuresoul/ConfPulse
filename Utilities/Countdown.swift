import SwiftUI

struct Countdown {
    let totalSeconds: Int
    let days: Int
    let hours: Int
    let minutes: Int

    // Splits the time left until the target date into days, hours and minutes
    init(to target: Date, from now: Date = .now) {
        totalSeconds = max(0, Int(target.timeIntervalSince(now)))
        days = totalSeconds / 86_400
        hours = totalSeconds % 86_400 / 3_600
        minutes = totalSeconds % 3_600 / 60
    }

    // True when the target date has already passed
    var isPast: Bool { totalSeconds == 0 }

    // True when the deadline is less than AppConfig.urgentDays away
    var isUrgent: Bool { !isPast && days < AppConfig.urgentDays }

    // Share of the countdown window still left: 1 = far away, 0 = now
    var progress: Double {
        min(1, Double(totalSeconds) / (AppConfig.countdownWindowDays * 86_400))
    }

    // Short label such as "12d 4h", "3h 20m" or "Closed"
    var shortText: String {
        if isPast { return "Closed" }
        if days > 0 { return "\(days)d \(hours)h" }
        return "\(hours)h \(minutes)m"
    }

    // Grey when closed, red when urgent, coral within a month, green otherwise
    var color: Color {
        if isPast { return .gray }
        if isUrgent { return .red }
        if days < 30 { return Theme.pulse }
        return .green
    }
}
