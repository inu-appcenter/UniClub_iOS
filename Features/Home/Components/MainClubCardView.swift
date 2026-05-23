import SwiftUI

struct MainClubCardView: View {
    @Environment(\.appMetrics) private var m

    let club: MainClubItem
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let isFavoriteLoading: Bool
    let onTap: () -> Void
    let onFavoriteTap: () -> Void

    var body: some View {
        Button(action: onTap) {
        ZStack(alignment: .top) {
            cardImage
                .frame(width: cardWidth, height: cardHeight)
                .clipped()

            Color(hex: 0x131313)
                .frame(height: 34)
                .frame(maxWidth: .infinity, alignment: .top)

            HStack(alignment: .center) {
                Text(club.name)
                    .font(AppTypography.notoSans(13, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Button(action: onFavoriteTap) {
                    Group {
                        if isFavoriteLoading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Image(systemName: club.favorite ? "heart.fill" : "heart")
                                .font(AppTypography.notoSans(m.space16, weight: .semibold))
                                .foregroundStyle(club.favorite ? AppColors.error : AppColors.background)
                        }
                    }
                    .frame(width: m.space24, height: m.space24)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, m.space10)
            .padding(.top, m.space10)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: m.radiusRecommendCard, style: .continuous))
        .buttonShadow(.medium)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var cardImage: some View {
        if let url = club.imageUrl {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    defaultClubImage
                case .failure:
                    defaultClubImage
                @unknown default:
                    defaultClubImage
                }
            }
        } else {
            defaultClubImage
        }
    }

    private var defaultClubImage: some View {
        Image("image_default_clubs")
            .resizable()
            .scaledToFill()
            .frame(width: cardWidth, height: cardHeight)
            .background(AppColors.fieldFill)
    }
}
