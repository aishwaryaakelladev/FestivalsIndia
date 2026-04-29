import Foundation

// I: Only what SettingsView needs.
protocol SettingsPresenting: AnyObject {
    var viewState: SettingsViewState { get }
    func toggleNotifications() async
    func openSystemSettings()
    func onAppear()
    func dismissAlert()
    func setAppearanceMode(_ mode: AppearanceMode)
}
