import SwiftUI

struct PromotionProfileHeader: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionDetailViewModel
    let onTapEdit: () -> Void
    let onNoLink: (String) -> Void

    private var topBackgroundHeight: CGFloat { m.scale * 276 }
    private var backgroundImageHeight: CGFloat { m.scale * 209 }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundImage
                .frame(maxWidth: .infinity, maxHeight: backgroundImageHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()

            HStack(alignment: .bottom, spacing: 0) {
                profileImageView
                    .frame(width: m.scale * 113, height: m.scale * 113)
                    .clipShape(RoundedRectangle(cornerRadius: m.radiusPromotionProfile, style: .continuous))
                    .padding(.leading, m.space24)
                    .padding(.bottom, m.scale * 15)

                Spacer()

                if let promo = vm.promotion {
                    socialRow(promo)
                        .padding(.trailing, m.scale * 21)
                        .padding(.bottom, m.space20)
                }
            }
        }
        .frame(height: topBackgroundHeight)
        .clipped()
    }

    @ViewBuilder
    private var backgroundImage: some View {
        if let url = vm.backgroundURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: defaultBackgroundAsset
                }
            }
        } else {
            defaultBackgroundAsset
        }
    }

    private var defaultBackgroundAsset: some View {
        Image("image_default_promotionbackground")
            .resizable()
            .scaledToFill()
    }

    @ViewBuilder
    private var profileImageView: some View {
        if let url = vm.profileURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: defaultProfileAsset
                }
            }
        } else {
            defaultProfileAsset
        }
    }

    private var defaultProfileAsset: some View {
        Image("image_default_promotionuser")
            .resizable()
            .scaledToFill()
    }

    private func socialRow(_ promo: PromotionService.ClubPromotionDTO) -> some View {
        HStack(spacing: m.space8) {
            if vm.canEdit {
                Button(action: onTapEdit) {
                    Text("편집")
                        .font(AppTypography.notoSans(10, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, m.space10)
                        .frame(height: m.scale * 26)
                        .background(AppColors.brand)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            if let raw = promo.applicationFormLink, let url = URL(string: raw) {
                Link(destination: url) {
                    Text("지원 링크")
                        .font(AppTypography.notoSans(10, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, m.space10)
                        .frame(height: m.scale * 26)
                        .background(AppColors.brand)
                        .clipShape(Capsule())
                }
            }
            socialIconButton(urlString: promo.youtubeLink,   assetName: "icon_link_youtube",   noLink: "해당 동아리는 유튜브를 지원하지 않습니다")
            socialIconButton(urlString: promo.instagramLink, assetName: "icon_link_instagram", noLink: "해당 동아리는 인스타를 지원하지 않습니다")
        }
    }

    private func socialIconButton(urlString: String?, assetName: String, noLink: String) -> some View {
        Group {
            if let raw = urlString, let url = URL(string: raw) {
                Link(destination: url) {
                    socialIconImage(assetName: assetName)
                }
            } else {
                Button { onNoLink(noLink) } label: {
                    socialIconImage(assetName: assetName)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(m.space2)
    }

    private func socialIconImage(assetName: String) -> some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(width: m.scale * 30, height: m.scale * 30)
    }
}
