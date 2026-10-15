import SwiftUI

final class BillStore: ObservableObject {
    @Published var bills: [Bill] = [] {
        didSet { save() }
    }

    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("bills.json")
    }()

    init() {
        // "-seed" launch flag fills the app with sample data (used for cloud screenshots).
        if ProcessInfo.processInfo.arguments.contains("-seed") {
            bills = Self.sampleBills()
        } else {
            load()
        }
    }

    private static func sampleBills() -> [Bill] {
        let now = Date().startOfMonth
        let electricity: [Double] = [104, 121, 172, 134, 88, 96]
        let gas: [Double] = [38, 52, 71, 45, 30, 28]
        let utility: [Double] = [62, 64, 66, 61, 59, 63]
        var out: [Bill] = []
        for i in 0..<6 {
            let m = now.addingMonths(-i)
            out.append(Bill(category: .rent, amount: 1450, month: m))
            out.append(Bill(category: .electricity, amount: electricity[i], month: m))
            out.append(Bill(category: .gas, amount: gas[i], month: m))
            out.append(Bill(category: .utility, amount: utility[i], month: m))
            out.append(Bill(category: .insurance, amount: 118, month: m))
            if i % 2 == 0 {
                out.append(Bill(category: .other, amount: 60, note: "Internet", month: m))
            }
        }
        return out
    }

    // MARK: - Editing

    func add(_ bill: Bill) { bills.append(bill) }

    func update(_ bill: Bill) {
        if let i = bills.firstIndex(where: { $0.id == bill.id }) {
            bills[i] = bill
        }
    }

    func delete(_ bill: Bill) {
        bills.removeAll { $0.id == bill.id }
    }

    // MARK: - Queries

    func bills(in month: Date) -> [Bill] {
        bills.filter { $0.month == month.startOfMonth }
            .sorted { $0.category.rawValue < $1.category.rawValue }
    }

    func total(in month: Date) -> Double {
        bills(in: month).reduce(0) { $0 + $1.amount }
    }

    func total(for category: BillCategory, in month: Date) -> Double {
        bills(in: month).filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }

    /// One entry per month that has at least one bill, oldest first.
    var monthlyTotals: [MonthTotal] {
        Dictionary(grouping: bills, by: { $0.month.startOfMonth })
            .map { MonthTotal(date: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.date < $1.date }
    }

    var mostExpensiveMonth: MonthTotal? { monthlyTotals.max { $0.total < $1.total } }
    var cheapestMonth: MonthTotal? { monthlyTotals.min { $0.total < $1.total } }

    var averagePerMonth: Double {
        let t = monthlyTotals
        guard !t.isEmpty else { return 0 }
        return t.reduce(0) { $0 + $1.total } / Double(t.count)
    }

    var allTimeTotal: Double { bills.reduce(0) { $0 + $1.amount } }

    var categoryTotals: [(category: BillCategory, total: Double)] {
        BillCategory.allCases
            .map { c in (c, bills.filter { $0.category == c }.reduce(0) { $0 + $1.amount }) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    var biggestCategory: (category: BillCategory, total: Double)? { categoryTotals.first }

    /// Change versus the previous month, if both months have data.
    func change(for month: Date) -> Double? {
        let current = total(in: month)
        let previous = total(in: month.addingMonths(-1))
        guard current > 0, previous > 0 else { return nil }
        return current - previous
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(bills)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Bill].self, from: data) else { return }
        bills = decoded
    }
}
