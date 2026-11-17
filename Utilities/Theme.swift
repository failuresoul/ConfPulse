import SwiftUI

enum Theme {
    static let pulse = Color(red: 1.0, green: 0.42, blue: 0.38)   // coral #FF6B61
    static let cornerRadius: CGFloat = 16

    struct CardStyle: ViewModifier {
        // Wraps content in a padded rounded card with a soft shadow
        func body(content: Content) -> some View {
            content
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
    }
}

extension View {
    // Applies the shared ConfPulse card look
    func cardStyle() -> some View {
        modifier(Theme.CardStyle())
    }
}
