import SwiftUI

struct PromotionEditFloatingTopBar: View {
    @Environment(\.appMetrics) private var m
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            IconButton.back(tint: .white) { onDismiss() }

            Spacer()

            Image(systemName: "gearshape.fill")
                .font(AppTypography.notoSans(18))
                .foregroundStyle(.white)
                .frame(width: m.controlHeight44, height: m.controlHeight44)
                .padding(.trailing, m.scale * 4)
        }
        .padding(.top, m.space18)
    }
}

struct PromotionEditStickyHeader: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionEditViewModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                IconButton.back { onDismiss() }

                Spacer()

                Text(vm.name)
                    .font(AppTypography.notoSans(13, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "gearshape.fill")
                    .font(AppTypography.notoSans(16))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: m.controlHeight44, height: m.controlHeight44)
            }
            .padding(.horizontal, m.horizontalPadding)
            .frame(height: m.scale * 54)
            .background(AppColors.background)

            Rectangle().fill(AppColors.separator).frame(height: 1)
        }
    }
}
