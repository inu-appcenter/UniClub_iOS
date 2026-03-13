//
//  QnADetailView.swift
//  UniClub
//
//  Created by 제욱 on 3/11/26.
//

import SwiftUI

struct QnADetailView: View {
    @Environment(\.appMetrics) private var m
    @StateObject private var viewModel: QnADetailViewModel

    let onBack: () -> Void
    let onCloseToHome: () -> Void
    let onEdit: (Int, QnAClubSummary?, String) -> Void

    @State private var showDeleteQuestionAlert: Bool = false
    @State private var pendingDeleteAnswer: QnAAnswerItem?

    @State private var selectedReplyTarget: QnAAnswerItem?
    @State private var isAnonymousReply: Bool = false
    @State private var isSubmittingReply: Bool = false

    @State private var activeMoreAnswer: QnAAnswerItem?

    init(
        questionId: Int,
        onBack: @escaping () -> Void,
        onCloseToHome: @escaping () -> Void,
        onEdit: @escaping (Int, QnAClubSummary?, String) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: QnADetailViewModel(questionId: questionId))
        self.onBack = onBack
        self.onCloseToHome = onCloseToHome
        self.onEdit = onEdit
    }

    var body: some View {
        ZStack {
            ScreenContainer(
                scroll: false,
                background: Color(hex: 0xF8F8F8),
                topPadding: .none,
                bottomPadding: .none
            ) { _ in
                VStack(alignment: .leading, spacing: m.space14) {
                    header
                        .padding(.top, m.space18)

                    detailContent

                    answerInputBar
                        .padding(.bottom, m.space16)
                }
            }

            if activeMoreAnswer != nil || pendingDeleteAnswer != nil || viewModel.showReportDialog {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if pendingDeleteAnswer == nil && !viewModel.showReportDialog {
                            activeMoreAnswer = nil
                        }
                    }
            }

            if let answer = activeMoreAnswer {
                answerActionSheet(for: answer)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if pendingDeleteAnswer != nil {
                deleteAnswerConfirmDialog
                    .transition(.opacity)
            }

            if viewModel.showReportDialog {
                QnAReportDialog(
                    title: viewModel.reportDialogTitle,
                    reason: $viewModel.reportReason,
                    isSubmitting: viewModel.isSubmittingReport,
                    onCancel: {
                        viewModel.dismissReportDialog()
                    },
                    onSubmit: {
                        Task {
                            _ = await viewModel.submitReport()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadDetail()
        }
        .alert("이 질문을 삭제하시겠습니까?", isPresented: $showDeleteQuestionAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                Task {
                    let success = await viewModel.deleteQuestion()
                    if success {
                        onBack()
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeMoreAnswer != nil)
        .animation(.easeInOut(duration: 0.2), value: pendingDeleteAnswer != nil)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showReportDialog)
    }

    private var header: some View {
        HStack {
            IconButton(systemName: "chevron.left") {
                onBack()
            }

            Spacer(minLength: 0)

            Text("질의응답")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: m.controlHeight44, height: m.controlHeight44)
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        if viewModel.isLoading {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else if let detail = viewModel.detail {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: m.space16) {
                    questionHeader(detail)

                    Rectangle()
                        .fill(Color(hex: 0xEBEBEB))
                        .frame(height: max(1, m.hairline))

                    ForEach(viewModel.topLevelAnswers) { answer in
                        VStack(alignment: .leading, spacing: m.space10) {
                            QnAAnswerRow(
                                answer: answer,
                                indentLevel: 0,
                                isReplyTarget: selectedReplyTarget?.answerId == answer.answerId,
                                onTapReply: {
                                    selectedReplyTarget = answer
                                },
                                onTapMore: answer.deleted ? nil : {
                                    activeMoreAnswer = answer
                                }
                            )

                            ForEach(viewModel.replies(for: answer.answerId)) { reply in
                                HStack(alignment: .top, spacing: m.space8) {
                                    Image("icon_answer_bindingarrow")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: m.space24, height: m.space24)
                                        .padding(.top, m.space12)

                                    QnAAnswerRow(
                                        answer: reply,
                                        indentLevel: 0,
                                        isReplyTarget: selectedReplyTarget?.answerId == reply.answerId,
                                        onTapReply: {
                                            selectedReplyTarget = reply
                                        },
                                        onTapMore: reply.deleted ? nil : {
                                            activeMoreAnswer = reply
                                        }
                                    )
                                }
                                .padding(.leading, m.space16)
                            }
                        }
                    }
                }
                .padding(.top, m.space4)
                .padding(.bottom, m.space8)
            }
        } else {
            VStack {
                Spacer()
                Text(viewModel.errorMessage ?? "질문 상세를 불러오지 못했습니다.")
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
            }
        }
    }

    private func questionHeader(_ detail: QnAQuestionDetail) -> some View {
        HStack(alignment: .top, spacing: m.space12) {
            mainQuestionAvatar(size: 35)

            VStack(alignment: .leading, spacing: m.space4) {
                HStack(spacing: m.space4) {
                    Text(detail.nickname)
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(AppColors.textPrimary)

                    if detail.president {
                        Circle()
                            .fill(Color(hex: 0xFF5900))
                            .frame(width: m.space6, height: m.space6)
                    }
                }

                Text(QnADateFormatter.display(detail.updatedAt))
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                Text("@\(detail.clubName)")
                    .font(AppTypography.captionStrong())
                    .foregroundStyle(Color(hex: 0xFF5900))
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
    private func mainQuestionAvatar(size: CGFloat) -> some View {
        if let profileURL = viewModel.detail?.profileURL {
            AsyncImage(url: profileURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    defaultMainQuestionAvatar(size: size)
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            defaultMainQuestionAvatar(size: size)
        }
    }

    private func defaultMainQuestionAvatar(size: CGFloat) -> some View {
        Image("image_default_user")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    private var answerInputBar: some View {
        HStack(spacing: m.space10) {
            Button {
                isAnonymousReply.toggle()
            } label: {
                Text("익명")
                    .font(AppTypography.captionStrong())
                    .foregroundStyle(isAnonymousReply ? .white : Color(hex: 0xBFBFBF))
                    .frame(width: 68, height: 48)
                    .background(isAnonymousReply ? Color(hex: 0xFF5900) : Color(hex: 0x2B2B2B))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(.plain)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: 0x2B2B2B))

                if viewModel.answerText.isEmpty {
                    Text("댓글을 입력하세요.")
                        .font(AppTypography.body())
                        .foregroundStyle(Color(hex: 0xBFBFBF))
                        .padding(.leading, m.space18)
                }

                HStack(spacing: m.space10) {
                    TextField("", text: $viewModel.answerText)
                        .font(AppTypography.body())
                        .foregroundStyle(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.leading, m.space18)

                    Button {
                        Task { await submitCurrentReply() }
                    } label: {
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

    @MainActor
    private func submitCurrentReply() async {
        let trimmed = viewModel.answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSubmittingReply else { return }

        isSubmittingReply = true
        defer { isSubmittingReply = false }

        do {
            _ = try await QnAService.createAnswer(
                questionId: viewModel.questionId,
                content: trimmed,
                anonymous: isAnonymousReply,
                parentAnswerId: selectedReplyTarget?.answerId
            )

            viewModel.answerText = ""
            selectedReplyTarget = nil
            isAnonymousReply = false
            await viewModel.loadDetail()
        } catch {
            viewModel.errorMessage = "댓글을 등록하지 못했습니다."
        }
    }

    @ViewBuilder
    private func answerActionSheet(for answer: QnAAnswerItem) -> some View {
        VStack(spacing: 0) {
            if answer.owner {
                Button {
                    activeMoreAnswer = nil
                    pendingDeleteAnswer = answer
                } label: {
                    sheetRow(title: "삭제하기")
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    activeMoreAnswer = nil
                    viewModel.presentReportDialog(target: .answer(id: answer.answerId))
                } label: {
                    sheetRow(title: "신고하기", iconSystemName: "exclamationmark.triangle")
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 307)
        .background(Color(hex: 0x2B2B2B))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.bottom, m.space16)
    }

    private func sheetRow(title: String, iconSystemName: String? = nil) -> some View {
        HStack(spacing: m.space12) {
            if let iconSystemName {
                Image(systemName: iconSystemName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
            }

            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(.white)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, m.space20)
        .frame(height: 48)
    }

    private var deleteAnswerConfirmDialog: some View {
        VStack(spacing: 0) {
            Text("이 댓글을 삭제하시겠습니까?")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, m.space24)
                .padding(.bottom, m.space24)

            HStack(spacing: 0) {
                Button("취소") {
                    pendingDeleteAnswer = nil
                }
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)

                Button("확인") {
                    if let answer = pendingDeleteAnswer {
                        Task {
                            await viewModel.deleteAnswer(answerId: answer.answerId)
                            pendingDeleteAnswer = nil
                        }
                    }
                }
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
        }
        .frame(maxWidth: 300)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
