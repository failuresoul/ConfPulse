import SwiftUI

struct ConferenceRowView: View {
    let conference: Conference

    var body: some View {
        // Redraws every minute so the countdown stays current
        TimelineView(.everyMinute) { context in
            let countdown = Countdown(to: conference.deadline, from: context.date)
            HStack(spacing: 14) {
                PulseRing(countdown: countdown)

                VStack(alignment: .leading, spacing: 4) {
                    Text(conference.name)
                        .font(.headline)
                    Text(conference.fullName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text("\(conference.area) · \(conference.location)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Deadline \(conference.deadline.formatted(date: .abbreviated, time: .omitted)) · \(countdown.shortText)")
                        .font(.caption.bold())
                        .foregroundStyle(countdown.color)
                }

                Spacer(minLength: 0)

                if let url = URL(string: conference.website) {
                    Link(destination: url) {
                        Image(systemName: "safari")
                            .font(.title3)
                    }
                }
            }
            .cardStyle()
        }
    }
}

#Preview {
    ConferenceRowView(conference: Conference(
        name: "DEMO", fullName: "Demo Conference on Previews", area: "ML",
        deadline: .now.addingTimeInterval(3 * 86_400),
        location: "Online", website: "https://example.com"))
    .padding()
}
