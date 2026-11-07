import SwiftUI
import Charts
import ZeusKit

/// One line in a chart. Color identifies the measure, not its rank, so it never changes
/// when another series is added or removed.
struct MetricSeries: Identifiable {
    let name: String
    let color: Color
    let points: [(date: Date, value: Double)]
    var id: String { name }
}

/// A single-axis time-series chart: 2pt lines, quiet grid, legend for 2+ series,
/// and a hover crosshair with a tooltip (text in primary ink, swatch carries identity).
struct MetricChart: View {
    let title: String
    let series: [MetricSeries]
    let format: (Double) -> String
    var domain: ClosedRange<Double>?

    @State private var hover: Date?

    private var all: [MetricSeries] { series.filter { !$0.points.isEmpty } }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            if all.isEmpty {
                Text("No data in this range").font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                chart.frame(height: 110)
                if all.count > 1 { legend }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var chart: some View {
        Chart {
            ForEach(all) { s in
                ForEach(s.points, id: \.date) { p in
                    LineMark(x: .value("Time", p.date), y: .value(s.name, p.value))
                        .foregroundStyle(by: .value("Series", s.name))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
            if let d = hover, let near = nearest(to: d) {
                RuleMark(x: .value("Time", near))
                    .foregroundStyle(.secondary.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .annotation(position: .top, spacing: 4,
                                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { tooltip(at: near) }
                ForEach(all) { s in
                    if let v = value(of: s, at: near) {
                        PointMark(x: .value("Time", near), y: .value(s.name, v))
                            .symbolSize(40).foregroundStyle(s.color)
                    }
                }
            }
        }
        .chartForegroundStyleScale(domain: all.map(\.name), range: all.map(\.color))
        .chartLegend(.hidden)
        .chartYScale(domain: yDomain)
        .chartXSelection(value: $hover)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { v in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.quaternary)
                AxisValueLabel { if let d = v.as(Double.self) { Text(format(d)).foregroundStyle(.secondary) } }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisValueLabel(format: .dateTime.hour().minute()).foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel(title)
        .accessibilityValue(summary)
    }

    private var yDomain: ClosedRange<Double> {
        if let domain { return domain }
        let top = all.flatMap { $0.points.map(\.value) }.max() ?? 1
        return 0...max(top * 1.15, 1)        // always anchored at zero
    }

    private var legend: some View {
        HStack(spacing: 12) {
            ForEach(all) { s in
                HStack(spacing: 4) {
                    Capsule().fill(s.color).frame(width: 14, height: 3)
                    Text(s.name).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func nearest(to date: Date) -> Date? {
        all.flatMap { $0.points.map(\.date) }.min { abs($0.timeIntervalSince(date)) < abs($1.timeIntervalSince(date)) }
    }

    private func value(of s: MetricSeries, at date: Date) -> Double? {
        s.points.first { $0.date == date }?.value
    }

    private func tooltip(at date: Date) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(date, format: .dateTime.hour().minute().second()).font(.caption2).foregroundStyle(.secondary)
            ForEach(all) { s in
                if let v = value(of: s, at: date) {
                    HStack(spacing: 4) {
                        Circle().fill(s.color).frame(width: 7, height: 7)
                        Text("\(s.name) \(format(v))").font(.caption).foregroundStyle(.primary)
                    }
                }
            }
        }
        .padding(6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
    }

    private var summary: String {
        all.map { s in
            let vs = s.points.map(\.value)
            return "\(s.name): latest \(format(vs.last ?? 0)), peak \(format(vs.max() ?? 0))"
        }.joined(separator: ". ")
    }
}

enum Fmt {
    static func percent(_ v: Double) -> String { v.formatted(.number.precision(.fractionLength(0...1))) + "%" }
    static func rate(_ v: Double) -> String { Measurement(value: v, unit: UnitInformationStorage.bytes)
        .converted(to: v >= 1_048_576 ? .megabytes : v >= 1024 ? .kilobytes : .bytes)
        .formatted(.measurement(width: .abbreviated, usage: .asProvided,
                                numberFormatStyle: .number.precision(.fractionLength(0...1)))) + "/s" }
}
