import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: BillStore
    @State private var month = Date().startOfMonth
    @State private var sheet: SheetItem?
    @State private var showBulk = false

    private struct SheetItem: Identifiable {
        let id = UUID()
        let bill: Bill?
        let presetCategory: BillCategory?
    }

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    monthPicker
                    totalCard
                    categoryGrid
                    billList
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }

            Menu {
                Button {
                    sheet = SheetItem(bill: nil, presetCategory: nil)
                } label: {
                    Label("Add one bill", systemImage: "plus.circle")
                }
                Button {
                    showBulk = true
                } label: {
                    Label("Add many months at once", systemImage: "calendar.badge.plus")
                }
            } label: {
                Label("Add", systemImage: "plus")
                    .glossyCapsule()
            }
            .padding(.trailing, 20)
            .padding(.bottom, 84)
        }
        .onAppear {
            // Launch flags used only for cloud screenshots.
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-add") {
                sheet = SheetItem(bill: nil, presetCategory: .electricity)
            }
            if args.contains("-bulk") {
                showBulk = true
            }
        }
        .sheet(isPresented: $showBulk) {
            BulkAddView()
                .environmentObject(store)
                .presentationDetents([.large])
        }
        .sheet(item: $sheet) { item in
            AddBillView(month: month, editing: item.bill, presetCategory: item.presetCategory)
                .environmentObject(store)
                .presentationDetents([.large])
        }
    }

    // MARK: - Pieces

    private var monthPicker: some View {
        HStack {
            BubbleIconButton(systemName: "chevron.left") {
                withAnimation(.spring) { month = month.addingMonths(-1) }
            }
            Spacer()
            Text(month.monthTitle)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(Aero.ink)
                .shadow(color: .white.opacity(0.7), radius: 1, y: 1)
            Spacer()
            BubbleIconButton(systemName: "chevron.right") {
                withAnimation(.spring) { month = month.addingMonths(1) }
            }
        }
    }

    private var totalCard: some View {
        VStack(spacing: 6) {
            Text("Total this month")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Aero.inkSoft)
            Text(store.total(in: month).money)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(Aero.ink)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText())

            if let diff = store.change(for: month) {
                HStack(spacing: 4) {
                    Image(systemName: diff > 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(abs(diff).money) \(diff > 0 ? "more" : "less") than last month")
                }
                .font(.system(.footnote, design: .rounded).weight(.bold))
                .foregroundStyle(diff > 0 ? Color.orange : Color(red: 0.1, green: 0.6, blue: 0.3))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .glassCard(cornerRadius: 36)
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(BillCategory.allCases) { cat in
                Button {
                    sheet = SheetItem(bill: nil, presetCategory: cat)
                } label: {
                    HStack(spacing: 12) {
                        CategoryBubble(category: cat)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cat.rawValue)
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                                .foregroundStyle(Aero.ink)
                            Text(store.total(for: cat, in: month).money)
                                .font(.system(.footnote, design: .rounded).weight(.semibold))
                                .foregroundStyle(Aero.inkSoft)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 26)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var billList: some View {
        let items = store.bills(in: month)
        return VStack(alignment: .leading, spacing: 12) {
            Text("Bills this month")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Aero.ink)
                .padding(.leading, 6)

            if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bubbles.and.sparkles.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Aero.inkSoft)
                    Text("No bills yet. Tap a bubble above or Add Bill!")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Aero.inkSoft)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .glassCard()
            } else {
                ForEach(items) { bill in
                    HStack(spacing: 12) {
                        CategoryBubble(category: bill.category, size: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bill.category.rawValue)
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                                .foregroundStyle(Aero.ink)
                            if !bill.note.isEmpty {
                                Text(bill.note)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(Aero.inkSoft)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Text(bill.amount.money)
                            .font(.system(.subheadline, design: .rounded).weight(.heavy))
                            .foregroundStyle(Aero.ink)
                        Button {
                            withAnimation(.spring) { store.delete(bill) }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Aero.inkSoft.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 24)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        sheet = SheetItem(bill: bill, presetCategory: nil)
                    }
                }
            }
        }
    }
}
