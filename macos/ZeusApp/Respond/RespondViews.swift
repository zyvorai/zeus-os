import SwiftUI
import ZeusKit

private func when(_ s: String?) -> Text {
    if let d = zeusDate(s) { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text(s ?? "—") }
}

private func enabledLabel(_ on: Bool?) -> some View {
    Label(on == true ? "Enabled" : (on == false ? "Disabled" : "—"),
          systemImage: on == true ? "checkmark.circle" : "pause.circle")
        .foregroundStyle(on == true ? Color.primary : Color.secondary)
}

/// Shared chrome: loader, reload button, polling lifecycle.
private struct ReloadingScreen<T: Sendable, Content: View>: View {
    let title: String
    @State var loader: Loader<T>
    @ViewBuilder var content: (T) -> Content

    var body: some View {
        LoadStateView(loader: loader, content: content)
            .navigationTitle(title)
            .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
            .task { loader.start() }
            .onDisappear { loader.stop() }
    }
}

// MARK: Alerting rules

struct RulesView: View {
    let client: ZeusClient

    var body: some View {
        ReloadingScreen(title: "Alert Rules", loader: Loader { try await client.alertingRules() }) { rules in
            if rules.isEmpty {
                ContentUnavailableView("No alert rules", systemImage: "bell.badge",
                                       description: Text("No alerting rules are defined on this server."))
            } else {
                Table(rules) {
                    TableColumn("Name") { Text($0.name ?? $0.ruleId) }
                    TableColumn("Severity") { Text($0.severity?.capitalized ?? "—") }.width(80)
                    TableColumn("Condition") { Text($0.condition?.summary ?? "—") }
                    TableColumn("State") { enabledLabel($0.enabled) }.width(100)
                    TableColumn("Channels") { Text(($0.notificationChannels ?? []).joined(separator: ", ")) }
                    TableColumn("Last triggered") { when($0.lastTriggered) }
                }
            }
        }
    }
}

// MARK: Channels (names and types only; configuration is never decoded)

struct ChannelsData: Sendable { let alerting: [AlertingChannel]; let notification: [NotificationChannel] }

struct ChannelsView: View {
    let client: ZeusClient

    var body: some View {
        ReloadingScreen(title: "Channels", loader: Loader {
            async let a = client.alertingChannels()
            async let n = client.notificationChannels()
            return try await ChannelsData(alerting: a, notification: n)
        }) { data in
            if data.alerting.isEmpty && data.notification.isEmpty {
                ContentUnavailableView("No channels", systemImage: "paperplane",
                                       description: Text("No notification channels are configured."))
            } else {
                VStack(spacing: 0) {
                    if !data.alerting.isEmpty {
                        Text("Alerting channels").font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                        Table(data.alerting) {
                            TableColumn("Name") { Text($0.name ?? $0.channelId) }
                            TableColumn("Type") { Text($0.channelType ?? "—") }
                            TableColumn("State") { enabledLabel($0.enabled) }
                            TableColumn("Created") { when($0.createdAt) }
                        }
                    }
                    if !data.notification.isEmpty {
                        Text("Notification channels").font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                        Table(data.notification) {
                            TableColumn("Name") { Text($0.name ?? $0.id) }
                            TableColumn("Type") { Text($0.channelType ?? "—") }
                            TableColumn("State") { enabledLabel($0.enabled) }
                            TableColumn("Last used") { when($0.lastUsed) }
                        }
                    }
                }
            }
        }
    }
}

// MARK: Notification history

struct NotificationHistoryView: View {
    let client: ZeusClient

    var body: some View {
        ReloadingScreen(title: "Notifications", loader: Loader { try await client.notificationHistory() }) { rows in
            if rows.isEmpty {
                ContentUnavailableView("No notifications sent", systemImage: "tray",
                                       description: Text("Nothing has been delivered yet."))
            } else {
                Table(rows) {
                    TableColumn("Sent") { when($0.sentAt) }.width(min: 90, ideal: 110)
                    TableColumn("Subject") { Text($0.subject ?? "—") }
                    TableColumn("Channel") { Text($0.channelType ?? $0.channelId ?? "—") }
                    TableColumn("Severity") { Text($0.severity?.capitalized ?? "—") }.width(80)
                    TableColumn("Status") { r in
                        let bad = r.error != nil || r.status?.lowercased() == "failed"
                        Label(r.status ?? "—", systemImage: bad ? "exclamationmark.triangle.fill" : "checkmark.circle")
                            .foregroundStyle(bad ? .orange : .primary)
                            .help(r.error ?? "")
                    }
                }
            }
        }
    }
}

// MARK: SLOs

struct SLOData: Sendable { let slos: [SLO]; let stats: SLOStats? }

struct SLOView: View {
    let client: ZeusClient

    var body: some View {
        ReloadingScreen(title: "SLOs", loader: Loader {
            async let s = client.slos()
            async let st = try? client.sloStats()
            return try await SLOData(slos: s, stats: await st)
        }) { data in
            VStack(spacing: 0) {
                if let s = data.stats {
                    Text("\(s.totalSlos ?? data.slos.count) SLOs · \(s.meetingTarget ?? 0) meeting target · \(s.atRisk ?? 0) at risk · \(s.violated ?? 0) violated")
                        .font(.callout).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                }
                if data.slos.isEmpty {
                    ContentUnavailableView("No SLOs", systemImage: "target", description: Text("No service level objectives are defined."))
                } else {
                    Table(data.slos) {
                        TableColumn("Name") { Text($0.name) }
                        TableColumn("Service") { Text($0.service ?? "—") }
                        TableColumn("Type") { Text($0.sloType ?? "—") }
                        TableColumn("Target") { Text($0.target.map { "\($0.formatted())%" } ?? "—") }.width(70)
                        TableColumn("Current") { Text($0.current.map { "\($0.formatted())%" } ?? "—") }.width(70)
                        TableColumn("Error budget") { s in
                            if let b = s.budgetRemaining {
                                HStack {
                                    Gauge(value: min(max(b, 0), 100), in: 0...100) { EmptyView() }
                                        .gaugeStyle(.accessoryLinearCapacity)
                                        .tint(b < 10 ? .red : (b < 30 ? .orange : .green))
                                    Text("\(b.formatted(.number.precision(.fractionLength(0...1))))%").monospacedDigit()
                                }
                            } else { Text("—") }
                        }.width(min: 140, ideal: 180)
                        TableColumn("Status") { Text($0.status ?? "—") }.width(90)
                        TableColumn("Window") { Text($0.timeWindow ?? "—") }.width(80)
                    }
                }
            }
        }
    }
}

// MARK: Incidents

struct IncidentsData: Sendable { let incidents: [AlertIncident]; let cluster: ClusterIncidents? }

struct IncidentsView: View {
    let client: ZeusClient
    @State private var selection: AlertIncident.ID?

    var body: some View {
        ReloadingScreen(title: "Incidents", loader: Loader {
            async let i = client.alertIncidents()
            async let c = try? client.clusterIncidents()
            return try await IncidentsData(incidents: i, cluster: await c)
        }) { data in
            VStack(spacing: 0) {
                if let h = data.cluster?.clusterHealth {
                    Text("Cluster \(h.status ?? "unknown") · \(h.readyNodes ?? 0)/\(h.totalNodes ?? 0) nodes ready · \(h.runningVms ?? 0)/\(h.totalVms ?? 0) VMs running · \(h.warningEventsLastHour ?? 0) warning events in the last hour")
                        .font(.callout).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                }
                if data.incidents.isEmpty && (data.cluster?.incidents.isEmpty ?? true) {
                    ContentUnavailableView("No incidents", systemImage: "checkmark.seal",
                                           description: Text("Nothing is open, and the cluster reports no incidents."))
                } else if data.incidents.isEmpty {
                    ContentUnavailableView("\(data.cluster?.incidents.count ?? 0) cluster incidents", systemImage: "exclamationmark.triangle",
                                           description: Text("The cluster reports incidents in a format this app does not display yet."))
                } else {
                    HSplitView {
                        Table(data.incidents, selection: $selection) {
                            TableColumn("Title") { Text($0.title ?? $0.incidentId) }
                            TableColumn("Severity") { Text($0.severity?.capitalized ?? "—") }.width(80)
                            TableColumn("Status") { Text($0.status?.capitalized ?? "—") }.width(80)
                            TableColumn("Opened") { when($0.createdAt) }
                        }
                        if let i = data.incidents.first(where: { $0.id == selection }) {
                            Form {
                                LabeledContent("Title", value: i.title ?? "—")
                                LabeledContent("Status", value: i.status ?? "—")
                                LabeledContent("Severity", value: i.severity ?? "—")
                                LabeledContent("Assigned to", value: i.assignedTo ?? "—")
                                LabeledContent("Alerts", value: "\(i.alertIds?.count ?? 0)")
                                LabeledContent("Opened") { when(i.createdAt) }
                                LabeledContent("Resolved") { when(i.resolvedAt) }
                                if let d = i.description, !d.isEmpty { Text(d).textSelection(.enabled) }
                            }
                            .formStyle(.grouped).frame(minWidth: 260, idealWidth: 320)
                        }
                    }
                }
            }
        }
    }
}

// MARK: Tenancy (read-only)

struct TenancyView: View {
    let client: ZeusClient

    var body: some View {
        ReloadingScreen(title: "Tenancy", loader: Loader { try await client.tenants() }) { tenants in
            if tenants.isEmpty {
                ContentUnavailableView("No tenants", systemImage: "building.2", description: Text("No tenants are defined."))
            } else {
                Table(tenants) {
                    TableColumn("Tenant") { Text($0.displayName ?? $0.name ?? $0.tenantId) }
                    TableColumn("Tier") { Text($0.tier?.capitalized ?? "—") }.width(80)
                    TableColumn("Status") { Text($0.status?.capitalized ?? "—") }.width(80)
                    TableColumn("Namespaces") { Text($0.namespaceCount.map(String.init) ?? "—") }.width(90)
                    TableColumn("CPU cores") { Text($0.totalCpuCores.map { $0.formatted(.number.precision(.fractionLength(0...2))) } ?? "—") }.width(80)
                    TableColumn("Memory GB") { Text($0.totalMemoryGb.map { $0.formatted(.number.precision(.fractionLength(0...2))) } ?? "—") }.width(90)
                }
            }
        }
    }
}
