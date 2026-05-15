import SwiftUI

struct LogoutConfirmOverlay: View {
    @Environment(\.appMetrics) private var m

    let onCancel: () -> Void
    let onConfirm: () -> Void

    private var dialogWidth: CGFloat { 220 * m.scale }
    private var dialogHeight: CGFloat { 80 * m.scale }

    var body: some View {
        ZStack {
            AppColors.grey800.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 0) {
                Text("로그아웃하시겠습니까?")
                    .font(AppTypography.notoSans(13 * m.scale, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, 13 * m.scale)

                Spacer(minLength: 0)

                HStack(spacing: 0) {
                    actionTextButton(
                        title: "닫기",
                        action: onCancel
                    )

                    Spacer(minLength: 0)

                    actionTextButton(
                        title: "확인",
                        action: onConfirm
                    )
                }
                .padding(.horizontal, 44 * m.scale)
                .padding(.bottom, 13 * m.scale)
            }
            .frame(width: dialogWidth, height: dialogHeight)
            .background(AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: 18 * m.scale))
        }
    }

    private func actionTextButton(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.notoSans(13 * m.scale))
                .foregroundStyle(AppColors.textPrimary)
                .frame(minWidth: 24 * m.scale)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
