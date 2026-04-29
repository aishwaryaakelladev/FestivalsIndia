import SwiftUI

@main
struct FestivalIndiaApp: App {

    private let container = DependencyContainer()
    @StateObject private var homePresenter: HomePresenter
    @AppStorage("appearanceMode") private var appearanceModeRaw: Int = AppearanceMode.system.rawValue

    init() {
        let container = DependencyContainer()
        _homePresenter = StateObject(wrappedValue: container.makeHomePresenter())
    }

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            HomeView(
                presenter: homePresenter,
                makeDetailView: { festivalID in
                    container.makeDetailView(for: festivalID)
                },
                makeSettingsView: {
                    container.makeSettingsView()
                }
            )
            .preferredColorScheme(appearanceMode.colorScheme)
        }
    }
}
