import SwiftUI

struct QnAAnswerInputBar: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var viewModel: QnADetailViewModel
    @Binding var isAnonymousReply: Bool
    let isSubmittingReply: Bool
    var focusBinding: FocusState<Bool>.Binding
    let onSubmit: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: m.space10) {
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

            HStack(alignment: .bottom, spacing: 0) {
                TextField("", text: $viewModel.answerText, axis: .vertical)
                    .font(AppTypography.body())
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .lineLimit(3)
                    .focused(focusBinding)
                    .padding(.horizontal, m.space18)
                    .padding(.vertical, m.space14)
                    .overlay(alignment: .topLeading) {
                        if viewModel.answerText.isEmpty {
                            Text("댓글을 입력하세요.")
                                .font(AppTypography.body())
                                .foregroundStyle(AppColors.grey400)
                                .padding(.horizontal, m.space18)
                                .padding(.vertical, m.space14)
                                .allowsHitTesting(false)
                        }
                    }

                Button(action: onSubmit) {
                    Image("icon_submit_uparrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .opacity(
                            viewModel.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? 0.5 : 1
                        )
                }
                .buttonStyle(.plain)
                .disabled(
                    viewModel.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || isSubmittingReply
                )
                .frame(width: 44, height: 48)
                .padding(.trailing, m.space4)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppColors.grey700)
            )
        }
    }
}
