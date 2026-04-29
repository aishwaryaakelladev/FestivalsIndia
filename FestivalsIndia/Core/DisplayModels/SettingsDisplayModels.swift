import SwiftUI

enum AppearanceMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsViewState {
    var notificationsEnabled: Bool
    var festivalCount: Int
    var regionCount: Int
    var appVersion: String
    var showOpenSettingsAlert: Bool
    var appearanceMode: AppearanceMode
}
