import SwiftUI

/// Add many bills across many months in one go:
/// 1) tap the months you want, 2) type each amount once, 3) save.
struct BulkAddView: View {
    @EnvironmentObject var store: BillStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMonths: Set<Date> = [Date().startOfMonth]
    @State private var amounts: [BillCategory: String] = [:]
    @State private var otherNote = ""
    @State private var replaceExisting = true

    private let monthColumns = [GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10)]

    /// Current month plus the 11 before it, newest first.
    private var monthOptions: [Date] {
        let now = Date().startOfMonth
        return (0..<12).map { now.addingMonths(-$0) }
    }

    private func value(_ category: BillCategory) -> Double {
        let text = (amounts[category] ?? "").replacingOccurrences(of: ",", with: ".")
        return Double(text) ?? 0
    }

    private var filledCategories: [BillCategory] {
        BillCategory.allCases.filter { value($0) > 0 }
    }

    private var billCount: Int { selectedMonths.count * filledCategories.count }

    private var grandTotal: Double {
        filledCategories.reduce(0) { $0 + value($1) } * Double(selectedMonths.count)
    }

    var body: some View {
        ZStack {
            AeroBackground()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    monthsCard
                    amountsCard
                    replaceCard
                    summary
                    Button("Save All") { save() }
                        .buttonStyle(GlossyButtonStyle())
                        .disabled(billCount == 0)
                        .opacity(billCount == 0 ? 0.5 : 1)
                }
                .padding(18)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Pieces

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Add Many Months")
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundStyle(Aero.ink)
                Text("Pick months, type amounts once")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Aero.inkSoft)
            }
            Spacer()
            BubbleIconButton(systemName: "xmark") { dismiss() }
        }
    }

    private var monthsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. Which months?")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Aero.ink)

            HStack(spacing: 8) {
                quickButton("Last 3") { selectLast(3) }
                quickButton("Last 6") { selectLast(6) }
                quickButton("Last 12") { selectLast(12) }
                quickButton("Clear") { selectedMonths = [] }
            }

            LazyVGrid(columns: monthColumns, spacing: 10) {
                ForEach(monthOptions, id: \.self) { month in
                    monthChip(month)
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 30)
    }

    private var amountsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. How much each month?")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Aero.ink)
            Text("Leave a bill empty to skip it.")
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundStyle(Aero.inkSoft)

            ForEach(BillCategory.allCases) { category in
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
                        CategoryBubble(category: category, size: 38)
                        Text(category.rawValue)
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(Aero.ink)
                        Spacer()
                        TextField("0.00", text: binding(for: category))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(.title3, design: .rounded).weight(.heavy))
                            .foregroundStyle(Aero.ink)
                            .frame(width: 120)
                    }
                    if category == .other {
                        TextField("What is it? e.g. Internet", text: $otherNote)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Aero.inkSoft)
                            .padding(.leading, 50)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.4))
                )
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 30)
    }

    private var replaceCard: some View {
        Toggle(isOn: $replaceExisting) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Replace existing bills")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Aero.ink)
                Text("Avoids doubles if you already added these bills in those months.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Aero.inkSoft)
            }
        }
        .tint(Aero.buttonBottom)
        .padding(16)
        .glassCard(cornerRadius: 26)
    }

    private var summary: some View {
        Text(billCount == 0
             ? "Pick at least one month and one amount."
             : "Adds \(billCount) bills across \(selectedMonths.count) months (\(grandTotal.money) total)")
            .font(.system(.subheadline, design: .rounded).weight(.bold))
            .foregroundStyle(Aero.ink)
            .multilineTextAlignment(.center)
    }

    private func quickButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(Aero.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Capsule().fill(.white.opacity(0.55)))
                .overlay(Capsule().stroke(.white, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func monthChip(_ month: Date) -> some View {
        let isOn = selectedMonths.contains(month)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                if isOn { selectedMonths.remove(month) } else { selectedMonths.insert(month) }
            }
        } label: {
            Text(month.formatted(.dateTime.month(.abbreviated).year()))
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(isOn ? Color.white : Aero.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    Capsule().fill(
                        isOn
                        ? AnyShapeStyle(LinearGradient(colors: [Aero.buttonTop, Aero.buttonBottom],
                                                       startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.45))
                    )
                )
                .overlay(Capsule().stroke(.white.opacity(0.9), lineWidth: 1.5))
                .scaleEffect(isOn ? 1.04 : 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func binding(for category: BillCategory) -> Binding<String> {
        Binding(
            get: { amounts[category] ?? "" },
            set: { amounts[category] = $0 }
        )
    }

    private func selectLast(_ n: Int) {
        selectedMonths = Set(monthOptions.prefix(n))
    }

    private func save() {
        let categories = filledCategories
        guard !categories.isEmpty, !selectedMonths.isEmpty else { return }

        var all = store.bills
        if replaceExisting {
            all.removeAll { bill in
                selectedMonths.contains(bill.month.startOfMonth) && categories.contains(bill.category)
            }
        }
        for month in selectedMonths.sorted() {
            for category in categories {
                all.append(Bill(category: category,
                                amount: value(category),
                                note: category == .other ? otherNote : "",
                                month: month))
            }
        }
        store.bills = all   // one assignment = one save
        dismiss()
    }
}
