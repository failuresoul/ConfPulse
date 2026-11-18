import SwiftUI

struct ConferenceRowView: View {
    let conference: Conference

    var body: some View {
        // Redraws every second so the countdown ticks
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let color = Countdown.color(until: conference.deadline, now: context.date)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(conference.name)
                        .font(.headline.bold())
                    Text(conference.area)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .foregroundStyle(Theme.pulse)
                        .background(Theme.pulse.opacity(0.15), in: Capsule())
                    Spacer()
                    if let url = URL(string: conference.website) {
                        Link(destination: url) {
                            Label("Website", systemImage: "safari")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Text(conference.fullName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Label(conference.location, systemImage: "mappin.and.ellipse")
                Label(conference.deadline.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")

                Text(Countdown.text(until: conference.deadline, now: context.date))
                    .font(.title3.monospacedDigit().bold())
                    .foregroundStyle(color)
            }
            .font(.caption)
            .padding(.leading, 6)
            .cardStyle()
            .overlay(alignment: .leading) {
                // Coloured urgency bar on the left edge of the card
                UnevenRoundedRectangle(topLeadingRadius: Theme.cornerRadius,
                                       bottomLeadingRadius: Theme.cornerRadius)
                    .fill(color)
                    .frame(width: 6)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ConferenceRowView(conference: Conference(
            name: "DEMO", fullName: "Demo Conference on Previews", area: "ML",
            deadline: .now.addingTimeInterval(3 * 86_400),
            location: "Online", website: "https://example.com"))
        ConferenceRowView(conference: Conference(
            name: "OLD", fullName: "A Conference That Already Closed", area: "CV",
            deadline: .now.addingTimeInterval(-86_400),
            location: "Online", website: "https://example.com"))
    }
    .padding()
}
