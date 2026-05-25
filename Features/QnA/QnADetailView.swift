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
    @State private var showMarkAnsweredDialog: Bool = false

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
                background: AppColors.backgroundSecondary,
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

            if activeMoreAnswer != nil || pendingDeleteAnswer != nil || showMarkAnsweredDialog || viewModel.showReportDialog || viewModel.showBlockDialog {
                AppColors.grey800.opacity(0.32)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if pendingDeleteAnswer == nil && !viewModel.showReportDialog && !viewModel.showBlockDialog {
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

            if showMarkAnsweredDialog {
                markAnsweredConfirmDialog
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

            if viewModel.showBlockDialog {
                QnABlockConfirmDialog(
                    title: viewModel.blockDialogTitle,
                    isSubmitting: viewModel.isSubmittingBlock,
                    onCancel: {
                        viewModel.dismissBlockDialog()
                    },
                    onConfirm: {
                        Task {
                            _ = await viewModel.submitBlock()
                            activeMoreAnswer = nil
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
        .animation(.easeInOut(duration: 0.2), value: viewModel.showBlockDialog)
    }

    private var header: some View {
        AppPageHeader(onBack: { onBack() }) {
            Text("질의응답")
                .foregroundStyle(AppColors.textPrimary)
        } trailing: {
            // B-QnA-4: 회장 + 미답변일 때 더보기 버튼
            if let detail = viewModel.detail, detail.president && !detail.answered {
                Button {
                    withAnimation { showMarkAnsweredDialog = true }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(AppTypography.notoSans(m.space18, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: m.controlHeight44, height: m.controlHeight44)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var markAnsweredConfirmDialog: some View {
        VStack(spacing: 0) {
            Text("답변 완료로 변경하시겠습니까?")
                .font(AppTypography.notoSans(14, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 28)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            Divider()

            HStack(spacing: 0) {
                Button("취소") {
                    withAnimation { showMarkAnsweredDialog = false }
                }
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 44)

                Divider().frame(height: 44)

                Button("확인") {
                    withAnimation { showMarkAnsweredDialog = false }
                    Task { await viewModel.markAnswered() }
                }
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.brand)
                .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .frame(width: 270)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: m.radius20))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
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
                        .fill(AppColors.separator)
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
        QnAQuestionHeader(detail: detail, profileURL: viewModel.detail?.profileURL)
    }

    private var answerInputBar: some View {
        QnAAnswerInputBar(
            viewModel: viewModel,
            isAnonymousReply: $isAnonymousReply,
            isSubmittingReply: isSubmittingReply,
            onSubmit: { Task { await submitCurrentReply() } }
        )
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

    private func answerActionSheet(for answer: QnAAnswerItem) -> some View {
        QnAAnswerActionSheet(
            answer: answer,
            onDelete: {
                activeMoreAnswer = nil
                pendingDeleteAnswer = answer
            },
            onReport: {
                activeMoreAnswer = nil
                viewModel.presentReportDialog(target: .answer(id: answer.answerId))
            },
            onBlock: {
                activeMoreAnswer = nil
                viewModel.presentBlockDialog(target: .answer(id: answer.answerId))
            }
        )
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
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
