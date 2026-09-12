import SwiftUI

enum PastelPalette {
    static func color(named name: String) -> Color {
        switch name {
        case "pink": return Color(red: 1.00, green: 0.72, blue: 0.82)
        case "brown": return Color(red: 0.87, green: 0.72, blue: 0.55)
        case "green": return Color(red: 0.70, green: 0.90, blue: 0.68)
        case "purple": return Color(red: 0.82, green: 0.73, blue: 0.98)
        case "orange": return Color(red: 1.00, green: 0.78, blue: 0.55)
        case "teal": return Color(red: 0.65, green: 0.90, blue: 0.88)
        case "blue": return Color(red: 0.68, green: 0.82, blue: 1.00)
        case "yellow": return Color(red: 1.00, green: 0.90, blue: 0.55)
        default: return Color(red: 0.85, green: 0.85, blue: 0.95)
        }
    }

    static let backgroundTop = Color(red: 1.00, green: 0.96, blue: 0.90)
    static let backgroundBottom = Color(red: 0.90, green: 0.95, blue: 1.00)

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, backgroundBottom], startPoint: .top, endPoint: .bottom)
    }
}
