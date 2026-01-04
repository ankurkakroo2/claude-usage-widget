import SwiftUI
import Shared

struct SettingsView: View {
    @State private var sessionKey = ""
    @State private var organizationId = ""
    @State private var isConfiguring = false
    @State private var statusMessage = ""
    @State private var refreshInterval: TimeInterval = 300

    var body: some View {
        Form {
            Section("Authentication") {
                SecureField("Session Key (sk-ant-...)", text: $sessionKey)
                    .font(.system(.body, design: .monospaced))
                    .help("Get this from claude.ai browser cookies")

                TextField("Organization ID (optional)", text: $organizationId)
                    .font(.system(.body, design: .monospaced))
                    .help("Leave empty to auto-fetch")

                HStack {
                    Button(isConfiguring ? "Configuring..." : "Save & Test") {
                        saveConfiguration()
                    }
                    .disabled(sessionKey.isEmpty || isConfiguring)

                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundStyle(statusMessage.hasPrefix("✅") ? .green : .red)
                    }
                }
            }

            Section("Refresh Interval") {
                Picker("Update every", selection: $refreshInterval) {
                    Text("1 minute").tag(TimeInterval(60))
                    Text("2 minutes").tag(TimeInterval(120))
                    Text("5 minutes").tag(TimeInterval(300))
                    Text("15 minutes").tag(TimeInterval(900))
                }
                .onChange(of: refreshInterval) { _, newValue in
                    if let appDelegate = NSApp.delegate as? AppDelegate {
                        appDelegate.menuBarController?.updateRefreshInterval(newValue)
                    }
                }
            }

            Section("How to Get Session Key") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Open claude.ai in your browser")
                        .font(.caption)
                    Text("2. Open Developer Tools (Cmd+Opt+I)")
                        .font(.caption)
                    Text("3. Go to Application → Cookies → claude.ai")
                        .font(.caption)
                    Text("4. Find 'sessionKey' and copy the value")
                        .font(.caption)
                    Text("5. Paste it above and click Save")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Section("Actions") {
                Button("Clear All Data") {
                    clearAllData()
                }
                .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 450)
        .onAppear {
            loadExistingConfig()
        }
    }

    private func loadExistingConfig() {
        if let existingKey = try? KeychainService.shared.loadSessionKey() {
            sessionKey = existingKey
        }
        if let existingOrgId = StorageService.shared.loadOrganizationId() {
            organizationId = existingOrgId
        }
        if let appDelegate = NSApp.delegate as? AppDelegate {
            refreshInterval = appDelegate.menuBarController?.refreshInterval ?? 300
        }
    }

    private func saveConfiguration() {
        guard !sessionKey.isEmpty else { return }

        isConfiguring = true
        statusMessage = "Configuring..."

        Task {
            do {
                guard let appDelegate = NSApp.delegate as? AppDelegate,
                      let controller = appDelegate.menuBarController else {
                    throw NSError(domain: "com.yourname.claude-usage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Menu bar controller not found"])
                }

                // If no org ID, fetch it
                let finalOrgId: String
                if organizationId.isEmpty {
                    statusMessage = "Fetching organization ID..."
                    finalOrgId = try await controller.fetchOrganizationId(sessionKey: sessionKey)
                    await MainActor.run {
                        organizationId = finalOrgId
                    }
                } else {
                    finalOrgId = organizationId
                }

                // Configure
                await controller.configure(sessionKey: sessionKey, organizationId: finalOrgId)

                await MainActor.run {
                    statusMessage = "✅ Configuration saved and tested!"
                    isConfiguring = false
                }

                // Auto-close after 2 seconds
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    statusMessage = ""
                }

            } catch {
                await MainActor.run {
                    statusMessage = "❌ \(error.localizedDescription)"
                    isConfiguring = false
                }
            }
        }
    }

    private func clearAllData() {
        KeychainService.shared.deleteSessionKey()
        StorageService.shared.clearAll()
        sessionKey = ""
        organizationId = ""
        statusMessage = "✅ All data cleared"

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                statusMessage = ""
            }
        }
    }
}

#Preview {
    SettingsView()
}
