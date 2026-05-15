import SwiftUI

struct QnAQuestionHeader: View {
    @Environment(\.appMetrics) private var m
    let detail: QnAQuestionDetail
    let profileURL: URL?

    var body: some View {
        HStack(alignment: .top, spacing: m.space12) {
            avatar(size: 35)

            VStack(alignment: .leading, spacing: m.space4) {
                HStack(spacing: m.space4) {
                    Text(detail.nickname)
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(AppColors.textPrimary)

                    if detail.president {
                        Circle()
                            .fill(AppColors.brand)
                            .frame(width: m.space6, height: m.space6)
                    }
                }

                Text(QnADateFormatter.display(detail.updatedAt))
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                Text("@\(detail.clubName)")
                    .font(AppTypography.captionStrong())
                    .foregroundStyle(AppColors.brand)
                    .padding(.top, m.space8)

                Text(detail.content)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, m.space2)
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func avatar(size: CGFloat) -> some View {
        if let profileURL {
            AsyncImage(url: profileURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    defaultAvatar(size: size)
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            defaultAvatar(size: size)
        }
    }

    private func defaultAvatar(size: CGFloat) -> some View {
        Image("image_default_user")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
