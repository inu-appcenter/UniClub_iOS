import SwiftUI

struct LogoutConfirmOverlay: View {
    @Environment(\.appMetrics) private var m

    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: m.space12) {
                Text("로그아웃하시겠습니까?")
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)

                HStack(spacing: m.space12) {
                    Button("닫기", action: onCancel)
                        .buttonStyle(.bordered)

                    Button("확인", action: onConfirm)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.primaryButtonFill)
                }
            }
            .padding(.vertical, m.space16)
            .padding(.horizontal, m.space18)
            .frame(maxWidth: min(m.contentMaxWidth, 320))
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: m.radius18))
            .padding(.horizontal, m.horizontalPadding)
        }
    }
}
