//
//  QnAListView.swift
//  UniClub
//
//  Created by 제욱 on 3/11/26.
//

import SwiftUI

struct QnAListView: View {
    @Environment(\.appMetrics) private var m
    @StateObject private var viewModel = QnAViewModel()

    let onBackToHome: () -> Void
    let onOpenDetail: (Int) -> Void
    let onOpenComposer: (QnAClubSummary?) -> Void

    @State private var isClubPickerPresented: Bool = false
    @State private var selectedActionQuestion: QnAQuestionSummary?
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var isShowingReportDialog: Bool = false
    @State private var reportReason: String = ""
    @State private var isSubmittingReport: Bool = false

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

                    QnASearchBar(
                        placeholder: "질문을 검색해보세요.",
                        text: $viewModel.keyword,
                        onSubmit: {
                            Task { await viewModel.loadQuestions() }
                        }
                    )
                    .onChange(of: viewModel.keyword) { _ in
                        viewModel.scheduleSearch()
                    }

                    QnAFilterBar(
                        selectedClubName: viewModel.selectedClub?.clubName,
                        onTapSelectClub: {
                            isClubPickerPresented = true
                        },
                        answeredOnly: viewModel.answeredOnly,
                        onToggleAnsweredOnly: {
                            viewModel.toggleAnsweredOnly()
                        },
                        onlyMyQuestions: viewModel.onlyMyQuestions,
                        onToggleOnlyMyQuestions: {
                            viewModel.toggleOnlyMyQuestions()
                        }
                    )

                    contentSection

                    PrimaryButton("질문하기") {
                        onOpenComposer(viewModel.selectedClub)
                    }
                    .padding(.bottom, m.space16)
                }
            }

            if selectedActionQuestion != nil {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if !isShowingDeleteConfirmation && !isShowingReportDialog {
                            selectedActionQuestion = nil
                        }
                    }

                VStack {
                    Spacer()
                    questionActionSheet
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
            }

            if isShowingDeleteConfirmation {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()

                deleteConfirmDialog
                    .transition(.opacity)
            }

            if isShowingReportDialog {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()

                QnAReportDialog(
                    title: "이 질문을 신고하시겠습니까?",
                    reason: $reportReason,
                    isSubmitting: isSubmittingReport,
                    onCancel: {
                        isShowingReportDialog = false
                        reportReason = ""
                    },
                    onSubmit: {
                        Task { await submitQuestionReport() }
                    }
                )
                .transition(.opacity)
            }
        }
        .task {
            await viewModel.initialLoadIfNeeded()
        }
        .fullScreenCover(isPresented: $isClubPickerPresented) {
            QnAClubPickerSheetView(
                initiallySelectedClub: viewModel.selectedClub,
                onSelect: { club in
                    viewModel.selectClub(club)
                }
            )
        }
        .animation(.easeInOut(duration: 0.2), value: selectedActionQuestion != nil)
        .animation(.easeInOut(duration: 0.2), value: isShowingDeleteConfirmation)
        .animation(.easeInOut(duration: 0.2), value: isShowingReportDialog)
    }

    private var header: some View {
        HStack {
            IconButton(systemName: "chevron.left") {
                onBackToHome()
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
    private var contentSection: some View {
        if viewModel.isLoading {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else if let errorMessage = viewModel.errorMessage {
            VStack(spacing: m.space12) {
                Spacer()

                Text(errorMessage)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textSecondary)

                Button("다시 시도") {
                    Task { await viewModel.loadQuestions() }
                }
                .font(AppTypography.captionStrong())
                .foregroundStyle(Color(hex: 0xFF5900))

                Spacer()
            }
        } else if viewModel.questions.isEmpty {
            VStack(alignment: .leading, spacing: m.space8) {
                Spacer()

                if let selectedClub = viewModel.selectedClub {
                    Text("@\(selectedClub.clubName)")
                        .font(AppTypography.captionStrong())
                        .foregroundStyle(Color(hex: 0xFF5900))

                    Text("동아리 부원들에게 궁금한 점을 물어보세요.")
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    Text("질문할 동아리를 선택해주세요.")
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: m.space14) {
                    ForEach(viewModel.questions) { question in
                        QnAQuestionCard(
                            profileURL: question.profileURL,
                            nickname: question.nickname,
                            updatedAt: question.updatedAt,
                            clubName: question.clubName,
                            content: question.content,
                            answerCount: question.countAnswer,
                            onTap: {
                                onOpenDetail(question.questionId)
                            },
                            onMore: {
                                selectedActionQuestion = question
                            }
                        )
                    }
                }
                .padding(.top, m.space4)
                .padding(.bottom, m.space8)
            }
        }
    }

    private var questionActionSheet: some View {
        VStack(spacing: 0) {
            if let question = selectedActionQuestion, question.owner {
                Button {
                    selectedActionQuestion = nil
                    onOpenDetail(question.questionId)
                } label: {
                    actionRow(
                        iconName: "icon_fix_pencil",
                        title: "수정하기"
                    )
                }
                .buttonStyle(.plain)

                Button {
                    isShowingDeleteConfirmation = true
                } label: {
                    actionRow(
                        iconName: "icon_delete_trashcan",
                        title: "삭제하기"
                    )
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    isShowingReportDialog = true
                } label: {
                    actionRow(
                        systemIconName: "exclamationmark.triangle",
                        title: "신고하기"
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 307)
        .background(Color(hex: 0x2B2B2B))
        .clipShape(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
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

    private var deleteConfirmDialog: some View {
        VStack(spacing: 0) {
            Text("이 질문을 삭제하시겠습니까?")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, m.space24)
                .padding(.bottom, m.space24)

            HStack(spacing: 0) {
                Button("취소") {
                    isShowingDeleteConfirmation = false
                }
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)

                Button("확인") {
                    Task {
                        if let question = selectedActionQuestion {
                            do {
                                try await QnAService.deleteQuestion(questionId: question.questionId)
                                isShowingDeleteConfirmation = false
                                selectedActionQuestion = nil
                                await viewModel.loadQuestions()
                            } catch {
                                isShowingDeleteConfirmation = false
                                selectedActionQuestion = nil
                            }
                        }
                    }
                }
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
        }
        .frame(maxWidth: 260)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @MainActor
    private func submitQuestionReport() async {
        guard let question = selectedActionQuestion else { return }

        let trimmedReason = reportReason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedReason.isEmpty, !isSubmittingReport else { return }

        isSubmittingReport = true
        defer { isSubmittingReport = false }

        do {
            try await QnAService.report(
                target: .question(id: question.questionId),
                reason: trimmedReason
            )
            isShowingReportDialog = false
            selectedActionQuestion = nil
            reportReason = ""
        } catch {
            isShowingReportDialog = false
            selectedActionQuestion = nil
            reportReason = ""
        }
    }
}
