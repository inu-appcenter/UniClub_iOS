import SwiftUI

struct PromotionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var m
    @StateObject private var vm: PromotionDetailViewModel
    @State private var noLinkMessage: String? = nil
    @State private var showNoApplyAlert = false
    @State private var navigateToEdit = false

    private let clubId: Int

    init(clubId: Int) {
        self.clubId = clubId
        _vm = StateObject(wrappedValue: PromotionDetailViewModel(clubId: clubId))
    }

    var body: some View {
        ScreenContainer(scroll: false, background: AppColors.backgroundTertiary, topPadding: .none, bottomPadding: .none) { _ in
            ZStack(alignment: .top) {
                scrollBody
                    .padding(.horizontal, -m.horizontalPadding)  // 이미지/콘텐츠만 풀-블리드
                AppPageHeader(onBack: { dismiss() }, tint: .white) {
                    EmptyView()
                } trailing: {
                    heartButton(filled: vm.isFavorite)
                }
            }
        }
        .modifier(NavBarHidden())
        .tabBarPresent(false)
        .task { await vm.load() }
        .navigationDestination(isPresented: $navigateToEdit) {
            PromotionEditView(clubId: clubId)
        }
        .alert(noLinkMessage ?? "", isPresented: Binding(
            get: { noLinkMessage != nil },
            set: { if !$0 { noLinkMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        }
        .alert("지원기간이 아닙니다", isPresented: $showNoApplyAlert) {
            Button("확인", role: .cancel) {}
        }
    }

    // MARK: - Scroll Body

    private var scrollBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topBackgroundSection
                if vm.isLoading && vm.promotion == nil {
                    loadingSection
                } else if let promo = vm.promotion {
                    contentSection(promo: promo)
                } else if let err = vm.errorMessage {
                    errorSection(err)
                }
            }
        }
    }

    // MARK: - Top Background Section

    private var topBackgroundSection: some View {
        PromotionProfileHeader(
            vm: vm,
            onTapEdit: { navigateToEdit = true },
            onNoLink: { noLinkMessage = $0 }
        )
    }

    // MARK: - Content Section

    private func contentSection(promo: PromotionService.ClubPromotionDTO) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            PromotionInfoSection(vm: vm, promo: promo)
                .padding(.top, m.space14)

            Rectangle()
                .fill(AppColors.separator)
                .frame(height: 1)
                .padding(.top, m.scale * 22)
                .padding(.horizontal, -m.space28)

            if let desc = promo.description, !desc.isEmpty {
                Text(desc)
                    .font(AppTypography.notoSans(13))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, m.scale * 36)
                    .padding(.leading, m.space12)
            }

            PromotionMediaStrip(vm: vm)
                .padding(.top, m.scale * 22)
                .padding(.horizontal, -m.space28)

            bottomButtons(promo: promo)
                .padding(.top, m.space24)
                .padding(.bottom, m.scale * 36)
        }
        .padding(.horizontal, m.space28)
    }


    // MARK: - Bottom Buttons

    private func bottomButtons(promo: PromotionService.ClubPromotionDTO) -> some View {
        HStack(spacing: m.space14) {
            Button {
                // TODO: navigate to QnAComposer
            } label: {
                Text("질문하기")
                    .font(AppTypography.notoSans(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: m.scale * 54)
                    .background(AppColors.grey700)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            let isClosed = promo.status == "CLOSED"
            if let raw = promo.applicationFormLink, let url = URL(string: raw), !isClosed {
                Link(destination: url) { applyButtonLabel(isClosed: false) }
            } else {
                Button {
                    if !isClosed { showNoApplyAlert = true }
                } label: { applyButtonLabel(isClosed: isClosed) }
                    .buttonStyle(.plain)
                    .disabled(isClosed)
            }
        }
    }

    private func applyButtonLabel(isClosed: Bool = false) -> some View {
        Text("지원하기")
            .font(AppTypography.notoSans(15))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: m.scale * 54)
            .background(isClosed ? Color(hex: 0x2A2A2A) : AppColors.brand)
            .clipShape(Capsule())
    }

    // MARK: - Heart Button

    private func heartButton(filled: Bool) -> some View {
        Button { Task { await vm.toggleFavorite() } } label: {
            Image(filled ? "icon_fullhart" : "icon_emptyhart")
                .resizable()
                .scaledToFit()
                .frame(width: m.scale * 27, height: m.scale * 23)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Loading / Error

    private var loadingSection: some View {
        VStack(spacing: m.space12) {
            ProgressView()
            Text("불러오는 중…")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, m.scale * 60)
    }

    private func errorSection(_ msg: String) -> some View {
        VStack(spacing: m.space12) {
            Text("오류가 발생했습니다")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)
            Text(msg)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Button { Task { await vm.load() } } label: {
                Text("다시 시도")
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, m.space16)
                    .padding(.vertical, m.space12)
                    .background(AppColors.cardFill)
                    .clipShape(RoundedRectangle(cornerRadius: m.radius18))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, m.scale * 60)
    }
}

// MARK: - Nav Bar Hidden

private struct NavBarHidden: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbar(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
        } else {
            content
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Preview

#Preview("PromotionDetailView") {
    NavigationStack {
        PromotionDetailView(clubId: 1)
    }
}
