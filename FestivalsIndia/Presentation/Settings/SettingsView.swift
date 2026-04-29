import SwiftUI

struct SettingsView<P: SettingsPresenting & ObservableObject>: View {
    @ObservedObject var presenter: P
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                notificationsSection
                statsSection
                howItWorksSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Notifications Disabled", isPresented: alertBinding) {
                Button("Open Settings") { presenter.openSystemSettings() }
                Button("Cancel", role: .cancel) { presenter.dismissAlert() }
            } message: {
                Text("Enable notifications for this app in Settings to receive festival reminders.")
            }
            .onAppear { presenter.onAppear() }
        }
    }

    // MARK: - Sections

    private var appearanceSection: some View {
        Section {
            Picker("Appearance", selection: appearanceModeBinding) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Appearance")
        }
    }

    private var notificationsSection: some View {
        Section {
            HStack(spacing: 16) {
                notificationIcon
                VStack(alignment: .leading, spacing: 3) {
                    Text("Festival Reminders")
                        .font(.body.weight(.medium))
                    Text("Notified at 9 AM the day before each festival")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: notificationToggleBinding)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Notifications")
        } footer: {
            Text("Reminders are scheduled for the next 5 years automatically.")
        }
    }

    private var notificationIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)
            Image(systemName: "bell.fill")
                .foregroundStyle(.white)
                .font(.title3)
        }
    }

    private var statsSection: some View {
        Section("About") {
            LabeledContent("Version", value: presenter.viewState.appVersion)
            LabeledContent("Festivals", value: "\(presenter.viewState.festivalCount)")
            LabeledContent("Regions", value: "\(presenter.viewState.regionCount)")
        }
    }

    private var howItWorksSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dynamic Dates")
                        .font(.body.weight(.medium))
                    Text("Fixed-date festivals (Pongal, Baisakhi, Makar Sankranti) compute correctly for any year. Lunisolar festivals use known date mappings through 2030.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("How It Works")
        }
    }

    // MARK: - Bindings

    private var notificationToggleBinding: Binding<Bool> {
        Binding(
            get: { presenter.viewState.notificationsEnabled },
            set: { _ in Task { await presenter.toggleNotifications() } }
        )
    }

    private var appearanceModeBinding: Binding<AppearanceMode> {
        Binding(
            get: { presenter.viewState.appearanceMode },
            set: { presenter.setAppearanceMode($0) }
        )
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { presenter.viewState.showOpenSettingsAlert },
            set: { if !$0 { presenter.dismissAlert() } }
        )
    }
}
