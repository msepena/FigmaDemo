import SwiftUI
import DesignSystem

/// Post-launch animated splash. Renders the same empty-grid card the iOS launch
/// screen image shows, then animates the X (top-left) and O (centre) marks into
/// the cells before fading out and signalling `onComplete`.
///
/// The static launch image (`LaunchLogo`) is rendered without marks for exactly
/// this purpose — when this view mounts, the launch image hands off seamlessly
/// because both compositions show the same card + grid.
public struct BrandSplashView: View {
    private let onComplete: () -> Void

    @State private var xVisible = false
    @State private var oVisible = false
    @State private var fadingOut = false

    /// `logoSize` matches `LaunchLogo`'s 1x natural size so the static and
    /// animated layers sit at the same on-screen size.
    private let logoSize: CGFloat = 200

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            DSColor.bg
                .ignoresSafeArea()
            SplashLogo(xVisible: xVisible, oVisible: oVisible)
                .frame(width: logoSize, height: logoSize)
        }
        .opacity(fadingOut ? 0 : 1)
        .task { await runReveal() }
    }

    private func runReveal() async {
        try? await Task.sleep(for: .milliseconds(120))
        withAnimation(.spring(duration: 0.35, bounce: 0.35)) { xVisible = true }
        try? await Task.sleep(for: .milliseconds(180))
        withAnimation(.spring(duration: 0.35, bounce: 0.35)) { oVisible = true }
        try? await Task.sleep(for: .milliseconds(700))
        withAnimation(.easeIn(duration: 0.35)) { fadingOut = true }
        try? await Task.sleep(for: .milliseconds(350))
        onComplete()
    }
}

private struct SplashLogo: View {
    let xVisible: Bool
    let oVisible: Bool

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let cardRadius = side * 0.18
            let gridInsetRatio: CGFloat = 0.10
            let gridInset = side * gridInsetRatio
            let gridSide = side - gridInset * 2
            let cellSize = gridSide / 3
            let lineWidth = side * 0.014

            ZStack {
                RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                    .fill(DSColor.cardBackground)
                    .shadow(color: .black.opacity(0.10), radius: side * 0.025, x: 0, y: side * 0.012)

                Path { path in
                    let originX = gridInset
                    let originY = gridInset
                    for i in 1...2 {
                        let x = originX + cellSize * CGFloat(i)
                        path.move(to: CGPoint(x: x, y: originY + lineWidth))
                        path.addLine(to: CGPoint(x: x, y: originY + gridSide - lineWidth))
                    }
                    for i in 1...2 {
                        let y = originY + cellSize * CGFloat(i)
                        path.move(to: CGPoint(x: originX + lineWidth, y: y))
                        path.addLine(to: CGPoint(x: originX + gridSide - lineWidth, y: y))
                    }
                }
                .stroke(
                    DSColor.gridLine,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

                markGlyph(.x, visible: xVisible)
                    .position(
                        x: gridInset + cellSize * 0.5,
                        y: gridInset + cellSize * 0.5
                    )
                markGlyph(.o, visible: oVisible)
                    .position(
                        x: gridInset + cellSize * 1.5,
                        y: gridInset + cellSize * 1.5
                    )
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func markGlyph(_ side: MarkGlyph.Side, visible: Bool) -> some View {
        MarkGlyph(
            side: side,
            font: .system(size: 56, weight: .bold, design: .rounded),
            xColorOverride: DSColor.playerXBlue
        )
        .scaleEffect(visible ? 1.0 : 0.6)
        .opacity(visible ? 1 : 0)
    }
}

#Preview("Splash mid-reveal") {
    BrandSplashView(onComplete: {})
}
