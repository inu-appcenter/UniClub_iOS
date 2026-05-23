import SwiftUI
import PhotosUI

struct PromotionEditMediaSection: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionEditViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: m.space12) {
            Text("대표이미지")
                .font(AppTypography.notoSans(13, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: m.space12) {
                    PhotosPicker(selection: .constant(nil), matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: m.scale * 25, style: .continuous)
                                .fill(AppColors.separatorLight)
                                .frame(width: m.scale * 139, height: m.scale * 183)
                            Image(systemName: "plus.circle")
                                .font(AppTypography.notoSans(24))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)

                    ForEach(vm.promotionImages) { media in
                        ZStack(alignment: .topTrailing) {
                            AsyncImage(url: media.url) { phase in
                                switch phase {
                                case .success(let img): img.resizable().scaledToFill()
                                default: AppColors.cardFill
                                }
                            }
                            .frame(width: m.scale * 139, height: m.scale * 183)
                            .clipShape(RoundedRectangle(cornerRadius: m.scale * 25, style: .continuous))

                            Button {
                                vm.promotionImages.removeAll { $0.id == media.id }
                            } label: {
                                // B-Promotion-5: 흰 원 + 진회색 X
                                Image(systemName: "xmark.circle.fill")
                                    .font(AppTypography.notoSans(20))
                                    .foregroundStyle(Color(hex: 0x2A2A2A))
                                    .background(Circle().fill(.white))
                            }
                            .buttonStyle(.plain)
                            .padding(m.space8)
                        }
                    }
                }
                .padding(.vertical, m.space4)
            }
            .padding(.horizontal, -m.space20)
        }
    }
}
