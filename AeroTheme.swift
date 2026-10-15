import SwiftUI

enum Aero {
    static let skyTop = Color(red: 0.33, green: 0.72, blue: 0.98)
    static let aqua = Color(red: 0.42, green: 0.90, blue: 0.93)
    static let grass = Color(red: 0.60, green: 0.90, blue: 0.48)
    static let ink = Color(red: 0.05, green: 0.24, blue: 0.42)
    static let inkSoft = Color(red: 0.10, green: 0.36, blue: 0.56)
    static let buttonTop = Color(red: 0.45, green: 0.85, blue: 1.00)
    static let buttonBottom = Color(red: 0.05, green: 0.50, blue: 0.85)
}

// MARK: - Background

struct AeroBackground: View {
    private struct Bubble: Identifiable {
        let id: Int
        let x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double
    }

    private let bubbles: [Bubble] = [
        .init(id: 0, x: 0.12, y: 0.10, size: 120, opacity: 0.35),
        .init(id: 1, x: 0.85, y: 0.18, size: 80, opacity: 0.30),
        .init(id: 2, x: 0.70, y: 0.42, size: 150, opacity: 0.22),
        .init(id: 3, x: 0.10, y: 0.55, size: 90, opacity: 0.28),
        .init(id: 4, x: 0.90, y: 0.72, size: 110, opacity: 0.30),
        .init(id: 5, x: 0.30, y: 0.85, size: 160, opacity: 0.25),
        .init(id: 6, x: 0.55, y: 0.05, size: 50, opacity: 0.35),
        .init(id: 7, x: 0.45, y: 0.65, size: 60, opacity: 0.30)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Aero.skyTop, Aero.aqua, Aero.grass],
                               startPoint: .top, endPoint: .bottom)

                // soft sun glow
                RadialGradient(colors: [.white.opacity(0.55), .clear],
                               center: .init(x: 0.2, y: 0.0),
                               startRadius: 5, endRadius: geo.size.width * 0.9)

                ForEach(bubbles) { b in
                    BubbleShape()
                        .frame(width: b.size, height: b.size)
                        .opacity(b.opacity + 0.35)
                        .position(x: geo.size.width * b.x, y: geo.size.height * b.y)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct BubbleShape: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(colors: [.white.opacity(0.10), .white.opacity(0.45)],
                               center: .center, startRadius: 0, endRadius: 80)
            )
            .overlay(
                Circle().stroke(
                    LinearGradient(colors: [.white.opacity(0.9), .white.opacity(0.1)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5)
            )
            .overlay(
                Ellipse()
                    .fill(.white.opacity(0.6))
                    .scaleEffect(x: 0.5, y: 0.25)
                    .offset(x: -8, y: -22)
                    .blur(radius: 2)
            )
    }
}

// MARK: - Glass card

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 28

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(colors: [.white.opacity(0.55), .white.opacity(0.15)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0.95), .white.opacity(0.2)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5)
            )
            .shadow(color: Aero.ink.opacity(0.18), radius: 14, x: 0, y: 8)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 28) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Glossy button

struct GlossyButtonStyle: ButtonStyle {
    var tint: Color = Aero.buttonBottom

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.bold))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    Capsule().fill(
                        LinearGradient(colors: [Aero.buttonTop, tint],
                                       startPoint: .top, endPoint: .bottom))
                    // gloss highlight
                    Capsule()
                        .fill(
                            LinearGradient(colors: [.white.opacity(0.75), .white.opacity(0.05)],
                                           startPoint: .top, endPoint: .bottom))
                        .padding(3)
                        .mask(VStack(spacing: 0) {
                            Rectangle().frame(height: 22)
                            Spacer(minLength: 0)
                        })
                }
            )
            .overlay(Capsule().stroke(.white.opacity(0.8), lineWidth: 1.5))
            .shadow(color: tint.opacity(0.5), radius: 10, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Glossy capsule look for non-Button views (e.g. a Menu label)

struct GlossyCapsule: ViewModifier {
    var tint: Color = Aero.buttonBottom

    func body(content: Content) -> some View {
        content
            .font(.system(.headline, design: .rounded).weight(.bold))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    Capsule().fill(
                        LinearGradient(colors: [Aero.buttonTop, tint],
                                       startPoint: .top, endPoint: .bottom))
                    Capsule()
                        .fill(
                            LinearGradient(colors: [.white.opacity(0.75), .white.opacity(0.05)],
                                           startPoint: .top, endPoint: .bottom))
                        .padding(3)
                        .mask(VStack(spacing: 0) {
                            Rectangle().frame(height: 22)
                            Spacer(minLength: 0)
                        })
                }
            )
            .overlay(Capsule().stroke(.white.opacity(0.8), lineWidth: 1.5))
            .shadow(color: tint.opacity(0.5), radius: 10, y: 6)
    }
}

extension View {
    func glossyCapsule(tint: Color = Aero.buttonBottom) -> some View {
        modifier(GlossyCapsule(tint: tint))
    }
}

// MARK: - Round glossy icon button (chevrons etc.)

struct BubbleIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Aero.ink)
                .frame(width: 42, height: 42)
                .background(
                    Circle().fill(
                        LinearGradient(colors: [.white.opacity(0.9), .white.opacity(0.35)],
                                       startPoint: .top, endPoint: .bottom))
                )
                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                .shadow(color: Aero.ink.opacity(0.2), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category bubble icon

struct CategoryBubble: View {
    let category: BillCategory
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            Circle().fill(
                LinearGradient(colors: [category.color.opacity(0.75), category.color],
                               startPoint: .top, endPoint: .bottom))
            Circle().stroke(.white.opacity(0.9), lineWidth: 1.5)
            Ellipse()
                .fill(.white.opacity(0.55))
                .frame(width: size * 0.6, height: size * 0.28)
                .offset(y: -size * 0.28)
            Image(systemName: category.symbol)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                .offset(y: size * 0.04)
        }
        .frame(width: size, height: size)
        .shadow(color: category.color.opacity(0.5), radius: 6, y: 3)
    }
}
