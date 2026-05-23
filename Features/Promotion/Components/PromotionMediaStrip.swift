import SwiftUI

struct PromotionMediaStrip: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionDetailViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: m.scale * 9) {
                if vm.promotionImages.isEmpty {
                    emptyMediaCard
                } else {
                    ForEach(Array(vm.promotionImages.enumerated()), id: \.element.id) { index, media in
                        let isLast = index == vm.promotionImages.count - 1
                        mediaCard(url: media.url, isLast: isLast)
                    }
                }
            }
            .padding(.vertical, m.space4)
            .padding(.leading, m.scale * 21)
        }
    }

    private var emptyMediaCard: some View {
        VStack(spacing: m.space8) {
            Text("아직 이미지가 없습니다.")
                .font(AppTypography.notoSans(12))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(width: m.scale * 139, height: m.scale * 183)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: m.scale * 25, style: .continuous))
        .shadow(color: AppColors.grey800.opacity(0.12), radius: m.scale * 4, x: 0, y: m.scale * 4)
    }

    private func mediaCard(url: URL?, isLast: Bool = false) -> some View {
        let w = isLast ? m.scale * 63 : m.scale * 139
        let r = m.scale * 25

        return Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: AppColors.cardFill
                    }
                }
            } else {
                AppColors.cardFill
            }
        }
        .frame(width: w, height: m.scale * 183)
        .clipShape(
            isLast
            // B-Promotion-2: 마지막 카드는 좌측만 둥근 모서리
            ? UnevenRoundedRectangle(
                topLeadingRadius: r, bottomLeadingRadius: r,
                bottomTrailingRadius: 0, topTrailingRadius: 0,
                style: .continuous
              )
            : UnevenRoundedRectangle(
                topLeadingRadius: r, bottomLeadingRadius: r,
                bottomTrailingRadius: r, topTrailingRadius: r,
                style: .continuous
              )
        )
        .shadow(color: AppColors.grey800.opacity(0.12), radius: m.scale * 4, x: 0, y: m.scale * 4)
    }
}
