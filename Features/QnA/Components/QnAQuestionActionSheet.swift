import SwiftUI

struct QnAQuestionActionSheet: View {
    @Environment(\.appMetrics) private var m
    let question: QnAQuestionSummary
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onReport: () -> Void
    let onBlock: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if question.owner {
                Button(action: onEdit) {
                    actionRow(iconName: "icon_fix_pencil", title: "수정하기")
                }
                .buttonStyle(.plain)

                Divider()
                    .background(AppColors.grey600)

                Button(action: onDelete) {
                    actionRow(iconName: "icon_delete_trashcan", title: "삭제하기")
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onReport) {
                    actionRow(systemIconName: "exclamationmark.triangle", title: "신고하기")
                }
                .buttonStyle(.plain)

                Divider()
                    .background(AppColors.grey600)

                Button(action: onBlock) {
                    actionRow(systemIconName: "nosign", title: "차단하기")
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.grey700)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, m.space16)
        .padding(.bottom, m.space16)
    }

    private func actionRow(
        iconName: String? = nil,
        systemIconName: String? = nil,
        title: String
    ) -> some View {
        HStack(spacing: m.space16) {
            if let iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else if let systemIconName {
                Image(systemName: systemIconName)
                    .font(AppTypography.notoSans(22, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
            }

            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(.white)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, m.space24)
        .frame(maxWidth: .infinity, minHeight: 64)
    }
}
