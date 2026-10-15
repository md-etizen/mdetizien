import SwiftUI

struct AddBillView: View {
    @EnvironmentObject var store: BillStore
    @Environment(\.dismiss) private var dismiss

    let month: Date
    let editing: Bill?

    @State private var category: BillCategory
    @State private var amountText: String
    @State private var note: String
    @FocusState private var amountFocused: Bool

    init(month: Date, editing: Bill?, presetCategory: BillCategory?) {
        self.month = month
        self.editing = editing
        _category = State(initialValue: editing?.category ?? presetCategory ?? .rent)
        _amountText = State(initialValue: editing.map { String($0.amount) } ?? "")
        _note = State(initialValue: editing?.note ?? "")
    }

    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            AeroBackground()

            ScrollView {
                VStack(spacing: 20) {
                    header

                    // Category picker
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(BillCategory.allCases) { cat in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                    category = cat
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    CategoryBubble(category: cat, size: 48)
                                    Text(cat.rawValue)
                                        .font(.system(.caption, design: .rounded).weight(.bold))
                                        .foregroundStyle(Aero.ink)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .glassCard(cornerRadius: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(category == cat ? cat.color : .clear, lineWidth: 3)
                                )
                                .scaleEffect(category == cat ? 1.05 : 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(Aero.inkSoft)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .focused($amountFocused)
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(Aero.ink)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(cornerRadius: 28)

                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category == .other ? "What is it?" : "Note (optional)")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(Aero.inkSoft)
                        TextField(category == .other ? "e.g. Internet, Phone" : "Add a note",
                                  text: $note)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Aero.ink)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(cornerRadius: 28)

                    Button(editing == nil ? "Save Bill" : "Save Changes") { save() }
                        .buttonStyle(GlossyButtonStyle())
                        .disabled(amount == nil || (amount ?? 0) <= 0)
                        .opacity((amount ?? 0) > 0 ? 1 : 0.5)
                        .padding(.top, 4)
                }
                .padding(18)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            if editing == nil { amountFocused = false }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(editing == nil ? "New Bill" : "Edit Bill")
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundStyle(Aero.ink)
                Text(month.monthTitle)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Aero.inkSoft)
            }
            Spacer()
            BubbleIconButton(systemName: "xmark") { dismiss() }
        }
    }

    private func save() {
        guard let amount, amount > 0 else { return }
        if var bill = editing {
            bill.category = category
            bill.amount = amount
            bill.note = note
            store.update(bill)
        } else {
            store.add(Bill(category: category, amount: amount, note: note, month: month.startOfMonth))
        }
        dismiss()
    }
}
