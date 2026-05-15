import SwiftUI

public struct AppPageHeader<Center: View, Trailing: View>: View {
    @Environment(\.appMetrics) private var m

    private let onBack: (() -> Void)?
    private let center: Center
    private let trailing: Trailing

    public init(
        onBack: (() -> Void)? = nil,
        @ViewBuilder center: () -> Center,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.onBack = onBack
        self.center = center()
        self.trailing = trailing()
    }

    public var body: some View {
        ZStack {
            center
                .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                if let onBack {
                    IconButton.back(action: onBack)
                } else {
                    Color.clear
                        .frame(width: m.controlHeight44, height: m.controlHeight44)
                }

                Spacer(minLength: 0)

                trailing
                    .frame(minWidth: m.controlHeight44, minHeight: m.controlHeight44)
            }
        }
        .padding(.top, m.space4)
        .frame(height: m.controlHeight44 + m.space4)
        .padding(.horizontal, m.space4 - m.horizontalPadding)
    }
}

// MARK: - Convenience — trailing 없는 경우

public extension AppPageHeader where Trailing == EmptyView {
    init(
        onBack: (() -> Void)? = nil,
        @ViewBuilder center: () -> Center
    ) {
        self.init(onBack: onBack, center: center, trailing: { EmptyView() })
    }
}
