import SwiftUI

enum BillCategory: String, Codable, CaseIterable, Identifiable {
    case rent = "Rent"
    case electricity = "Electricity"
    case gas = "Gas"
    case utility = "Utility"
    case insurance = "Insurance"
    case other = "Other"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .rent: return "house.fill"
        case .electricity: return "bolt.fill"
        case .gas: return "flame.fill"
        case .utility: return "drop.fill"
        case .insurance: return "shield.fill"
        case .other: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .rent: return Color(red: 0.25, green: 0.62, blue: 0.98)
        case .electricity: return Color(red: 1.00, green: 0.80, blue: 0.20)
        case .gas: return Color(red: 1.00, green: 0.55, blue: 0.25)
        case .utility: return Color(red: 0.20, green: 0.80, blue: 0.85)
        case .insurance: return Color(red: 0.45, green: 0.82, blue: 0.40)
        case .other: return Color(red: 0.72, green: 0.52, blue: 0.95)
        }
    }
}

struct Bill: Identifiable, Codable, Hashable {
    var id = UUID()
    var category: BillCategory
    var amount: Double
    var note: String = ""
    /// Always the first day of the month this bill belongs to.
    var month: Date
}

struct MonthTotal: Identifiable {
    let date: Date
    let total: Double
    var id: Date { date }
}

extension Double {
    var money: String {
        formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}

extension Date {
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? self
    }

    func addingMonths(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: n, to: self)?.startOfMonth ?? self
    }

    var monthTitle: String {
        formatted(.dateTime.month(.wide).year())
    }

    var monthShort: String {
        formatted(.dateTime.month(.abbreviated))
    }
}
