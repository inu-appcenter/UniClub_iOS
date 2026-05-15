import SwiftUI

struct PromotionFloatingTopBar: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionDetailViewModel
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            IconButton.back(tint: .white) { onDismiss() }

            Spacer()

            heartButton
                .padding(.trailing, m.scale * 21)
        }
        .padding(.top, m.space18)
        .padding(.leading, m.scale * 3)
    }

    private var heartButton: some View {
        Button { Task { await vm.toggleFavorite() } } label: {
            Image(vm.isFavorite ? "icon_fullhart" : "icon_emptyhart")
                .resizable()
                .scaledToFit()
                .frame(width: m.scale * 27, height: m.scale * 23)
        }
        .buttonStyle(.plain)
    }
}

struct PromotionStickyHeader: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionDetailViewModel
    let promo: PromotionService.ClubPromotionDTO
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                IconButton.back { onDismiss() }
                    .padding(.leading, m.scale * 3)

                Spacer()

                HStack(spacing: m.space6) {
                    Text(promo.name)
                        .font(AppTypography.notoSans(13, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    statusCapsule
                }

                Spacer()

                heartButton
                    .frame(width: m.controlHeight44, height: m.controlHeight44)
            }
            .padding(.horizontal, m.horizontalPadding)
            .frame(height: m.scale * 54)
            .background(AppColors.background)

            Rectangle()
                .fill(AppColors.separator)
                .frame(height: 1)
        }
    }

    private var statusCapsule: some View {
        let status = vm.promotion?.status ?? ""
        let bg: Color = {
            switch status {
            case "CLOSED", "SCHEDULED": return AppColors.grey400
            default:                    return Color(hex: 0x353535)
            }
        }()
        return Text(vm.statusText)
            .font(AppTypography.notoSans(10))
            .foregroundStyle(.white)
            .padding(.horizontal, m.space10)
            .frame(height: m.scale * 18)
            .background(bg)
            .clipShape(Capsule())
    }

    private var heartButton: some View {
        Button { Task { await vm.toggleFavorite() } } label: {
            Image(vm.isFavorite ? "icon_fullhart" : "icon_emptyhart")
                .resizable()
                .scaledToFit()
                .frame(width: m.scale * 27, height: m.scale * 23)
        }
        .buttonStyle(.plain)
    }
}
