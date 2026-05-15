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
                    ForEach(vm.promotionImages) { media in
                        mediaCard(url: media.url)
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

    private func mediaCard(url: URL?) -> some View {
        Group {
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
        .frame(width: m.scale * 139, height: m.scale * 183)
        .clipShape(RoundedRectangle(cornerRadius: m.scale * 25, style: .continuous))
        .shadow(color: AppColors.grey800.opacity(0.12), radius: m.scale * 4, x: 0, y: m.scale * 4)
    }
}
