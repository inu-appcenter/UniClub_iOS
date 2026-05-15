//
//  QnAComposerView.swift
//  UniClub
//
//  Created by 제욱 on 3/11/26.
//

import SwiftUI

struct QnAComposerView: View {
    @Environment(\.appMetrics) private var m
    @StateObject private var viewModel: QnAComposerViewModel

    let onDismiss: () -> Void

    @State private var isClubPickerPresented: Bool = false

    init(
        questionId: Int? = nil,
        selectedClub: QnAClubSummary? = nil,
        initialContent: String = "",
        onDismiss: @escaping () -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: QnAComposerViewModel(
                questionId: questionId,
                selectedClub: selectedClub,
                initialContent: initialContent
            )
        )
        self.onDismiss = onDismiss
    }

    var body: some View {
        ScreenContainer(
            scroll: false,
            background: .white,
            topPadding: .none,
            bottomPadding: .none
        ) { _ in
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, m.space18)

                clubSelector
                    .padding(.top, m.space16)

                divider
                    .padding(.top, m.space18)

                contentSection
                    .padding(.top, m.space24)

                Spacer(minLength: 0)

                bottomBar
                    .padding(.bottom, m.space16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $isClubPickerPresented) {
            QnAClubPickerSheetView(
                initiallySelectedClub: viewModel.selectedClub,
                onSelect: { club in
                    viewModel.selectedClub = club
                }
            )
        }
    }

    private var header: some View {
        HStack {
            IconButton.back { onDismiss() }

            Spacer(minLength: 0)

            Text(viewModel.isEditMode ? "질문 수정" : "질문하기")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: m.controlHeight44, height: m.controlHeight44)
        }
    }

    private var clubSelector: some View {
        Button {
            guard !viewModel.isEditMode else { return }
            isClubPickerPresented = true
        } label: {
            HStack(spacing: m.space8) {
                Text(viewModel.selectedClub?.clubName ?? "질문할 동아리를 검색하세요.")
                    .font(AppTypography.body())
                    .foregroundStyle(viewModel.selectedClub == nil ? AppColors.textSecondary : AppColors.textPrimary)

                Spacer(minLength: 0)

                Image(systemName: "magnifyingglass")
                    .font(AppTypography.notoSans(m.space16, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, m.space12)
            .frame(height: m.controlHeight44)
            .background(AppColors.fieldFill)
            .clipShape(RoundedRectangle(cornerRadius: m.radius16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isEditMode)
        .opacity(viewModel.isEditMode ? 0.75 : 1)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.separator)
            .frame(height: max(1, m.hairline))
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: m.space10) {
            if let selectedClub = viewModel.selectedClub {
                Text("@\(selectedClub.clubName)")
                    .font(AppTypography.captionStrong())
                    .foregroundStyle(AppColors.brand)
            }

            Text("동아리 부원들에게 궁금한 것을 물어보세요.")
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textSecondary)

            TextEditor(text: $viewModel.content)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.top, m.space6)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption())
                    .foregroundStyle(.red)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: m.space12) {
            Button {
                viewModel.toggleAnonymous()
            } label: {
                Text("익명")
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(.white)
                    .frame(width: 68, height: 48)
                    .background(
                        viewModel.isAnonymous
                        ? AppColors.brand
                        : AppColors.grey300
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                Task {
                    let success = await viewModel.submit()
                    if success {
                        onDismiss()
                    }
                }
            } label: {
                Text(viewModel.isEditMode ? "수정하기" : "등록하기")
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        AppColors.grey700
                            .opacity(viewModel.isSubmitEnabled ? 1 : 0.35)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isSubmitEnabled)
        }
    }
}
