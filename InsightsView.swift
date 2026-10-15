import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var store: BillStore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Insights")
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                    .foregroundStyle(Aero.ink)
                    .shadow(color: .white.opacity(0.7), radius: 1, y: 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 6)

                if store.monthlyTotals.isEmpty {
                    emptyState
                } else {
                    statGrid
                    chartCard
                    categoryCard
                }
                Spacer(minLength: 110)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
        }
    }

    // MARK: - Pieces

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 44))
                .foregroundStyle(Aero.inkSoft)
            Text("Add some bills and your stats will float in here.")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Aero.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .glassCard(cornerRadius: 32)
    }

    private var statGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
        return LazyVGrid(columns: columns, spacing: 14) {
            if let m = store.mostExpensiveMonth {
                StatBubble(title: "Most Expensive", value: m.total.money,
                           subtitle: m.date.monthTitle, symbol: "arrow.up.circle.fill",
                           color: .orange)
            }
            if let m = store.cheapestMonth {
                StatBubble(title: "Cheapest", value: m.total.money,
                           subtitle: m.date.monthTitle, symbol: "arrow.down.circle.fill",
                           color: Color(red: 0.2, green: 0.7, blue: 0.4))
            }
            StatBubble(title: "Monthly Average", value: store.averagePerMonth.money,
                       subtitle: "\(store.monthlyTotals.count) months tracked",
                       symbol: "equal.circle.fill", color: Aero.buttonBottom)
            if let c = store.biggestCategory {
                StatBubble(title: "Biggest Category", value: c.category.rawValue,
                           subtitle: c.total.money, symbol: c.category.symbol,
                           color: c.category.color)
            }
        }
    }

    private var chartCard: some View {
        let totals = store.monthlyTotals
        let maxDate = store.mostExpensiveMonth?.date
        let minDate = store.cheapestMonth?.date
        return VStack(alignment: .leading, spacing: 12) {
            Text("Month by month")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Aero.ink)

            Chart(totals) { m in
                BarMark(
                    x: .value("Month", m.date, unit: .month),
                    y: .value("Total", m.total)
                )
                .cornerRadius(10)
                .foregroundStyle(
                    LinearGradient(
                        colors: [barColor(m.date, maxDate, minDate).opacity(0.6),
                                 barColor(m.date, maxDate, minDate)],
                        startPoint: .top, endPoint: .bottom)
                )
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .frame(height: 200)

            HStack(spacing: 14) {
                legend(.orange, "Highest")
                legend(Color(red: 0.2, green: 0.7, blue: 0.4), "Lowest")
                legend(Aero.buttonBottom, "Other")
            }
            .font(.system(.caption, design: .rounded).weight(.semibold))
            .foregroundStyle(Aero.inkSoft)
        }
        .padding(18)
        .glassCard(cornerRadius: 32)
    }

    private var categoryCard: some View {
        let totals = store.categoryTotals
        let all = max(store.allTimeTotal, 0.01)
        return VStack(alignment: .leading, spacing: 14) {
            Text("Where it goes")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Aero.ink)

            ForEach(totals, id: \.category) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        CategoryBubble(category: item.category, size: 30)
                        Text(item.category.rawValue)
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(Aero.ink)
                        Spacer()
                        Text(item.total.money)
                            .font(.system(.subheadline, design: .rounded).weight(.heavy))
                            .foregroundStyle(Aero.ink)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.5))
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [item.category.color.opacity(0.7), item.category.color],
                                    startPoint: .top, endPoint: .bottom))
                                .frame(width: max(12, geo.size.width * item.total / all))
                                .overlay(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 32)
    }

    // MARK: - Helpers

    private func barColor(_ date: Date, _ maxDate: Date?, _ minDate: Date?) -> Color {
        if store.monthlyTotals.count > 1 {
            if date == maxDate { return .orange }
            if date == minDate { return Color(red: 0.2, green: 0.7, blue: 0.4) }
        }
        return Aero.buttonBottom
    }

    private func legend(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(text)
        }
    }
}

struct StatBubble: View {
    let title: String
    let value: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbol)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(Aero.inkSoft)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(Aero.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(subtitle)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(Aero.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard(cornerRadius: 28)
    }
}
