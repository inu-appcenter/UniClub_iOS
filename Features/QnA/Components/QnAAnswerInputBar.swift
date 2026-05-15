import SwiftUI

struct QnAAnswerInputBar: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var viewModel: QnADetailViewModel
    @Binding var isAnonymousReply: Bool
    let isSubmittingReply: Bool
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: m.space10) {
            Button {
                isAnonymousReply.toggle()
            } label: {
                Text("익명")
                    .font(AppTypography.captionStrong())
                    .foregroundStyle(isAnonymousReply ? .white : AppColors.grey400)
                    .frame(width: 68, height: 48)
                    .background(isAnonymousReply ? AppColors.brand : AppColors.grey700)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(.plain)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppColors.grey700)

                if viewModel.answerText.isEmpty {
                    Text("댓글을 입력하세요.")
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.grey400)
                        .padding(.leading, m.space18)
                }

                HStack(spacing: m.space10) {
                    TextField("", text: $viewModel.answerText)
                        .font(AppTypography.body())
                        .foregroundStyle(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.leading, m.space18)

                    Button(action: onSubmit) {
                        Image("icon_submit_uparrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .opacity(
                                viewModel.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? 0.5
                                : 1
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        viewModel.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || isSubmittingReply
                    )
                    .padding(.trailing, m.space14)
                }
            }
            .frame(height: 48)
        }
    }
}
