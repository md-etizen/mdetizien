import SwiftUI

enum AppTab: String, CaseIterable {
    case bills = "Bills"
    case insights = "Insights"

    var symbol: String {
        switch self {
        case .bills: return "list.bullet.rectangle.fill"
        case .insights: return "chart.bar.fill"
        }
    }
}

struct ContentView: View {
    @State private var tab: AppTab =
        ProcessInfo.processInfo.arguments.contains("-insights") ? .insights : .bills

    var body: some View {
        ZStack(alignment: .bottom) {
            AeroBackground()

            Group {
                switch tab {
                case .bills: HomeView()
                case .insights: InsightsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BubbleTabBar(selection: $tab)
                .padding(.bottom, 8)
        }
    }
}

struct BubbleTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.self) { t in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selection = t
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: t.symbol)
                        Text(t.rawValue)
                    }
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(selection == t ? .white : Aero.ink)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if selection == t {
                                Capsule().fill(
                                    LinearGradient(colors: [Aero.buttonTop, Aero.buttonBottom],
                                                   startPoint: .top, endPoint: .bottom))
                                    .overlay(Capsule().stroke(.white.opacity(0.8), lineWidth: 1.5))
                                    .shadow(color: Aero.buttonBottom.opacity(0.5), radius: 6, y: 3)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .glassCard(cornerRadius: 40)
    }
}
