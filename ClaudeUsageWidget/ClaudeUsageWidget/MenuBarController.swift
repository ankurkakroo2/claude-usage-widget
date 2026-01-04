import AppKit
import SwiftUI
import WidgetKit
import Shared

@MainActor
final class MenuBarController: ObservableObject {
    @Published var usageData: UsageData?
    @Published var billingData: BillingData?
    @Published var isRefreshing = false
    @Published var lastError: String?
    @Published var refreshInterval: TimeInterval = 300 // 5 minutes
    @Published var lastUpdateTime: Date?

    private var statusItem: NSStatusItem?
    private var refreshTimer: Timer?
    private var sessionKey: String?
    private var organizationId: String?

    init() {
        setupMenuBar()
        Task {
            await initialSetup()
        }
    }

    // MARK: - Menu Bar Setup

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "chart.bar.fill", accessibilityDescription: "Claude Usage")
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }

        print("✅ Menu bar item created")
    }

    @objc private func statusBarButtonClicked() {
        showMenu()
    }

    private func showMenu() {
        let menu = NSMenu()

        // Title
        let titleItem = NSMenuItem(title: "Claude Usage Widget", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(NSMenuItem.separator())

        // Usage info
        if let usage = usageData {
            let sessionItem = NSMenuItem(
                title: "Session: \(Int(usage.fiveHour.remainingPercent))% left",
                action: nil,
                keyEquivalent: ""
            )
            sessionItem.isEnabled = false
            menu.addItem(sessionItem)

            let weeklyItem = NSMenuItem(
                title: "Weekly: \(Int(usage.sevenDay.remainingPercent))% left",
                action: nil,
                keyEquivalent: ""
            )
            weeklyItem.isEnabled = false
            menu.addItem(weeklyItem)

            if let billing = billingData {
                let creditsItem = NSMenuItem(
                    title: "Credits: $\(String(format: "%.2f", billing.dollars))",
                    action: nil,
                    keyEquivalent: ""
                )
                creditsItem.isEnabled = false
                menu.addItem(creditsItem)
            }

            if let lastUpdate = lastUpdateTime {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .abbreviated
                let timeStr = formatter.localizedString(for: lastUpdate, relativeTo: Date())
                let updateItem = NSMenuItem(
                    title: "Updated: \(timeStr)",
                    action: nil,
                    keyEquivalent: ""
                )
                updateItem.isEnabled = false
                menu.addItem(updateItem)
            }
        } else {
            let noDataItem = NSMenuItem(title: "No data available", action: nil, keyEquivalent: "")
            noDataItem.isEnabled = false
            menu.addItem(noDataItem)
        }

        menu.addItem(NSMenuItem.separator())

        // Error display
        if let error = lastError {
            let errorItem = NSMenuItem(title: "⚠️ \(error)", action: nil, keyEquivalent: "")
            errorItem.isEnabled = false
            menu.addItem(errorItem)
            menu.addItem(NSMenuItem.separator())
        }

        // Refresh
        let refreshItem = NSMenuItem(title: isRefreshing ? "Refreshing..." : "Refresh Now", action: #selector(refreshNow), keyEquivalent: "r")
        refreshItem.target = self
        refreshItem.isEnabled = !isRefreshing
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        // Quit
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    // MARK: - Initial Setup

    private func initialSetup() async {
        print("🔧 Starting initial setup...")

        // Try to load cached credentials; if missing, auto-detect via browser cookies
        if let cachedKey = try? KeychainService.shared.loadSessionKey(),
           let cachedOrgId = StorageService.shared.loadOrganizationId() {
            print("✅ Found cached credentials")
            sessionKey = cachedKey
            organizationId = cachedOrgId
            await refreshUsage()
        } else {
            print("⚠️ No cached credentials found, attempting auto-detect via browser cookies")
            await autoDetectAndConfigure()
        }

        // Start auto-refresh timer
        startRefreshTimer()
    }

    // MARK: - Refresh Logic

    @objc func refreshNow() {
        Task {
            await refreshUsage()
        }
    }

    func refreshUsage() async {
        guard !isRefreshing else {
            print("⏭️ Already refreshing, skipping")
            return
        }

        guard let sessionKey = sessionKey,
              let organizationId = organizationId else {
            lastError = "No session key configured"
            print("❌ \(lastError!)")
            return
        }

        isRefreshing = true
        defer { isRefreshing = false }

        print("🔄 Refreshing usage data...")

        do {
            // Fetch usage
            let usage = try await ClaudeAPIService.shared.fetchUsage(
                organizationId: organizationId,
                sessionKey: sessionKey
            )
            usageData = usage

            // Fetch billing (optional)
            let billing = try? await ClaudeAPIService.shared.fetchCredits(
                organizationId: organizationId,
                sessionKey: sessionKey
            )
            billingData = billing

            // Create snapshot for widget
            let snapshot = WidgetSnapshot(
                usage: usage,
                billing: billing,
                generatedAt: Date()
            )

            // Save to shared storage
            StorageService.shared.saveSnapshot(snapshot)

            // Reload widgets
            WidgetCenter.shared.reloadAllTimelines()

            lastUpdateTime = Date()
            lastError = nil

            print("✅ Refresh complete")

        } catch {
            lastError = error.localizedDescription
            print("❌ Refresh failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Timer

    private func startRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshUsage()
            }
        }
        print("⏰ Refresh timer started (every \(Int(refreshInterval/60))min)")
    }

    func updateRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = interval
        startRefreshTimer()
    }

    // MARK: - Configuration

    func configure(sessionKey: String, organizationId: String) async {
        print("🔧 Configuring with new credentials...")

        // Save to secure storage
        try? KeychainService.shared.saveSessionKey(sessionKey)
        StorageService.shared.saveOrganizationId(organizationId)

        self.sessionKey = sessionKey
        self.organizationId = organizationId

        // Fetch immediately
        await refreshUsage()
    }

    func fetchOrganizationId(sessionKey: String) async throws -> String {
        print("🌐 Fetching organization ID...")
        let orgId = try await ClaudeAPIService.shared.fetchOrganizationId(sessionKey: sessionKey)
        return orgId
    }

    // MARK: - Auto-detect (default flow)

    private func autoDetectAndConfigure() async {
        do {
            let detectedSession = try BrowserCookieService.fetchSessionKey()
            let orgId = try await fetchOrganizationId(sessionKey: detectedSession)

            // Persist
            try? KeychainService.shared.saveSessionKey(detectedSession)
            StorageService.shared.saveOrganizationId(orgId)

            // Update in-memory state
            sessionKey = detectedSession
            organizationId = orgId

            print("✅ Auto-detected session and org; refreshing data")
            await refreshUsage()
        } catch {
            lastError = "Auto-detect failed: \(error.localizedDescription)"
            print("❌ Auto-detect failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions

    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
