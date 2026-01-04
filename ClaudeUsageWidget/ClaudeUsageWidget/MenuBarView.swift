import SwiftUI
import Shared

struct MenuBarView: View {
    @EnvironmentObject var controller: MenuBarController

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Claude Usage")
                    .font(.system(.headline, design: .monospaced))
                Spacer()
                Button {
                    Task {
                        await controller.refreshUsage()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(controller.isRefreshing)
            }
            .padding()

            Divider()

            // Usage Stats
            if let usage = controller.usageData {
                VStack(alignment: .leading, spacing: 12) {
                    // 5-Hour Stats
                    VStack(alignment: .leading, spacing: 4) {
                        Text("5-Hour Usage")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                        HStack {
                            ProgressView(value: usage.fiveHour.utilization, total: 100)
                                .frame(maxWidth: .infinity)
                            Text("\(Int(usage.fiveHour.utilization))%")
                                .font(.system(.body, design: .monospaced))
                                .monospacedDigit()
                        }
                        Text("Resets: \(usage.fiveHour.resetsAt, style: .relative)")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // 7-Day Stats
                    VStack(alignment: .leading, spacing: 4) {
                        Text("7-Day Usage")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                        HStack {
                            ProgressView(value: usage.sevenDay.utilization, total: 100)
                                .frame(maxWidth: .infinity)
                            Text("\(Int(usage.sevenDay.utilization))%")
                                .font(.system(.body, design: .monospaced))
                                .monospacedDigit()
                        }
                        Text("Resets: \(usage.sevenDay.resetsAt, style: .relative)")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            } else if controller.isRefreshing {
                ProgressView()
                    .padding()
            } else if let error = controller.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("No data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }

            Divider()

            // Billing Info
            if let billing = controller.billingData {
                HStack {
                    Text("Credits:")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(billing.dollars, specifier: "%.2f")")
                        .font(.system(.body, design: .monospaced))
                        .monospacedDigit()
                }
                .padding()
            }

            Divider()

            // Actions
            HStack(spacing: 0) {
                Button("Settings") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                Divider()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .frame(width: 300)
    }
}
