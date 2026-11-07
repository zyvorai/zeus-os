import SwiftUI
import ZeusKit

struct ComplianceDetailData: Sendable { let detail: ComplianceFrameworkDetail; let cis: CISReport? }

/// Control-level drill-down for one framework. Shows what the server reports; when it reports
/// no per-control data (as on some installs) the view says so instead of inventing rows.
struct ComplianceDetailView: View {
    let framework: ComplianceFramework
    @State private var loader: Loader<ComplianceDetailData>
    @Environment(\.dismiss) private var dismiss

    init(client: ZeusClient, framework: ComplianceFramework) {
        self.framework = framework
        let isCIS = framework.frameworkType?.uppercased() == "CIS"
        _loader = State(initialValue: Loader {
            async let d = client.complianceFrameworkDetail(framework.name)
            async let c: CISReport? = isCIS ? try? await client.cisReport() : nil
            return try await ComplianceDetailData(detail: d, cis: await c)
        })
    }

    var body: some View {
        NavigationStack {
            LoadStateView(loader: loader) { data in
                List {
                    summary(data.detail)
                    ForEach(data.detail.sections) { s in
                        Section(s.title ?? s.id) {
                            if s.controls.isEmpty { Text("No controls listed.").foregroundStyle(.secondary) }
                            ForEach(s.controls) { ControlRow(control: $0) }
                        }
                    }
                    if let cis = data.cis {
                        ForEach(cis.sections) { s in
                            Section("CIS \(s.title ?? s.sectionId)") {
                                ForEach(s.checks) { c in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack { Text(c.checkId).monospaced(); Spacer(); Text(c.result ?? "—").foregroundStyle(.secondary) }
                                        Text(c.description ?? "").font(.callout)
                                        if let r = c.remediation, !r.isEmpty { Text(r).font(.caption).foregroundStyle(.secondary) }
                                    }
                                }
                            }
                        }
                        if !cis.recommendations.isEmpty {
                            Section("Recommendations") {
                                // The server repeats the same recommendation once per failing resource; show each once.
                                ForEach(Array(NSOrderedSet(array: cis.recommendations)) as? [String] ?? cis.recommendations, id: \.self) { Text($0) }
                            }
                        }
                    }
                    if data.detail.sections.isEmpty && (data.cis?.sections.isEmpty ?? true) {
                        Section {
                            ContentUnavailableView("No control detail", systemImage: "list.bullet.rectangle",
                                description: Text("The server reports scores for \(framework.name) but no per-control results."))
                        }
                    }
                }
            }
            .navigationTitle(framework.frameworkType ?? framework.name)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .task { loader.start(polling: false) }
        }
        .frame(minWidth: 520, minHeight: 460)
    }

    @ViewBuilder private func summary(_ d: ComplianceFrameworkDetail) -> some View {
        Section("Summary") {
            if let t = d.description, !t.isEmpty { Text(t) }
            LabeledContent("Controls", value: "\(framework.passedControls) passed of \(framework.totalControls)")
            if let n = d.totalIssues { LabeledContent("Open issues", value: "\(n)") }
            if let n = d.autoRemediable { LabeledContent("Auto-remediable", value: "\(n)") }
        }
    }
}

private struct ControlRow: View {
    let control: ComplianceControl
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 6) {
                if let d = control.description, !d.isEmpty { Text(d) }
                if let r = control.remediation, !r.isEmpty { Text("Fix: \(r)").foregroundStyle(.secondary) }
                if let r = control.resourcesAffected, !r.isEmpty { Text("Affected: \(r.joined(separator: ", "))").font(.caption) }
            }.frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            HStack {
                Image(systemName: control.isFailing ? "xmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(control.isFailing ? .red : .green)
                Text("\(control.id)  \(control.title ?? "")")
                Spacer()
                if let s = control.severity { Text(s).font(.caption).foregroundStyle(.secondary) }
            }
        }
    }
}
