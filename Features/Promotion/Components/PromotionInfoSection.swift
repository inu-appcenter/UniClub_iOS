import SwiftUI

struct PromotionInfoSection: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionDetailViewModel
    let promo: PromotionService.ClubPromotionDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            clubInfoBlock
                .padding(.top, m.space14)

            if let tagline = promo.simpleDescription, !tagline.isEmpty {
                taglineStrip(tagline)
                    .padding(.top, m.scale * 25)
            }

            recruitNoticeBlock
                .padding(.top, m.space32)
        }
    }

    // MARK: - Club Info Block

    private var clubInfoBlock: some View {
        VStack(alignment: .leading, spacing: m.space12) {
            HStack(spacing: -m.space8) {
                Text(promo.name)
                    .font(AppTypography.notoSans(13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, m.space14)
                    .frame(height: m.scale * 30)
                    .background(AppColors.brand)
                    .clipShape(Capsule())

                statusCapsule
                    .zIndex(1)
            }

            HStack(spacing: m.space24) {
                if let v = promo.location       { miniInfo("동아리방", v) }
                if let v = promo.presidentName  { miniInfo("회장",    v) }
                if let v = promo.presidentPhone { miniInfo("연락처",  v) }
            }
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
            .frame(height: m.space18)
            .background(bg)
            .clipShape(Capsule())
    }

    private func miniInfo(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: m.space2) {
            Text(title)
                .font(AppTypography.notoSans(10, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            Text(value)
                .font(AppTypography.notoSans(9))
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    // MARK: - Tagline Strip

    private func taglineStrip(_ text: String) -> some View {
        Text(text)
            .font(AppTypography.notoSans(10, weight: .bold))
            .foregroundStyle(AppColors.brand)
            .padding(.leading, m.scale * 33)
            .padding(.top, m.space12)
            .padding(.bottom, m.space8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.background)
            .shadow(
                color: Color(hex: 0x999999).opacity(0.19),
                radius: m.scale * 17,
                x: m.space14,
                y: m.space2
            )
            .padding(.horizontal, -m.space28)
    }

    // MARK: - Recruit / Notice Block

    private var recruitNoticeBlock: some View {
        VStack(alignment: .leading, spacing: m.space12) {
            infoRow("모집기간", vm.recruitPeriod ?? "")
            infoRow("공지",    promo.notice ?? "")
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: m.space18) {
            Text(label)
                .font(AppTypography.notoSans(10, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: m.scale * 40, alignment: .leading)
            Text(value)
                .font(AppTypography.notoSans(10, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
    }
}
