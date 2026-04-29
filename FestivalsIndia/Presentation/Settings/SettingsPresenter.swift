import UIKit
import Combine

// S: Only drives SettingsView. Delegates notification work to the service.
final class SettingsPresenter: ObservableObject, SettingsPresenting {

    @Published private(set) var viewState: SettingsViewState

    private let repository: FestivalRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    private let yearRange: ClosedRange<Int>

    init(
        repository: FestivalRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        yearRange: ClosedRange<Int>? = nil
    ) {
        self.repository = repository
        self.notificationService = notificationService
        let year = Calendar.current.component(.year, from: .now)
        self.yearRange = yearRange ?? year...(year + 5)
        let savedAppearance = AppearanceMode(rawValue: UserDefaults.standard.integer(forKey: "appearanceMode")) ?? .system
        self.viewState = SettingsViewState(
            notificationsEnabled: false,
            festivalCount: repository.fetchAll().count,
            regionCount: Region.allCases.filter { $0 != .all }.count,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            showOpenSettingsAlert: false,
            appearanceMode: savedAppearance
        )
    }

    // MARK: - SettingsPresenting

    func onAppear() {
        notificationService.refreshStatus()
        viewState.notificationsEnabled = notificationService.authorizationStatus == .authorized
    }

    func toggleNotifications() async {
        if viewState.notificationsEnabled {
            await notificationService.cancelAllReminders()
            await MainActor.run { viewState.notificationsEnabled = false }
        } else {
            let granted = await notificationService.requestPermission()
            if granted {
                await notificationService.scheduleReminders(for: repository.fetchAll(), years: yearRange)
                await MainActor.run { viewState.notificationsEnabled = true }
            } else {
                await MainActor.run { viewState.showOpenSettingsAlert = true }
            }
        }
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func dismissAlert() {
        viewState.showOpenSettingsAlert = false
    }

    func setAppearanceMode(_ mode: AppearanceMode) {
        viewState.appearanceMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "appearanceMode")
    }
}
