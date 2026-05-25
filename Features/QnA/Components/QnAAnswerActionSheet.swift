import SwiftUI

struct QnAAnswerActionSheet: View {
    @Environment(\.appMetrics) private var m
    let answer: QnAAnswerItem
    let onDelete: () -> Void
    let onReport: () -> Void
    let onBlock: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if answer.owner {
                Button(action: onDelete) {
                    sheetRow(title: "삭제하기")
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onReport) {
                    sheetRow(title: "신고하기", iconSystemName: "exclamationmark.triangle")
                }
                .buttonStyle(.plain)

                Divider()
                    .background(AppColors.grey600)

                Button(action: onBlock) {
                    sheetRow(title: "차단하기", iconSystemName: "nosign")
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

    private func sheetRow(title: String, iconSystemName: String? = nil) -> some View {
        HStack(spacing: m.space12) {
            if let iconSystemName {
                Image(systemName: iconSystemName)
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
