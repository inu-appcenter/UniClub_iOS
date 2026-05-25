import SwiftUI
import PhotosUI

struct PromotionEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var m
    @StateObject private var vm: PromotionEditViewModel

    @State private var showNoLinkAlert = false

    // B-Promotion-4: 카드형 인라인 링크 입력 (Q-7)
    private enum LinkTarget { case youtube, instagram, application }
    @State private var activeLinkTarget: LinkTarget? = nil
    @State private var linkDraft: String = ""

    init(clubId: Int) {
        _vm = StateObject(wrappedValue: PromotionEditViewModel(clubId: clubId))
    }

    var body: some View {
        ScreenContainer(scroll: false, background: AppColors.backgroundTertiary, topPadding: .none, bottomPadding: .none) { _ in
            ZStack(alignment: .top) {
                scrollBody
                    .padding(.horizontal, -m.horizontalPadding)  // 이미지/콘텐츠만 풀-블리드
                AppPageHeader(onBack: { dismiss() }, tint: .white) {
                    EmptyView()
                } trailing: {
                    Image(systemName: "gearshape.fill")
                        .font(AppTypography.notoSans(18))
                        .foregroundStyle(.white)
                        .frame(width: m.controlHeight44, height: m.controlHeight44)
                }

                // B-Promotion-4: 카드형 인라인 링크 입력 (화면 중앙 정렬)
                if activeLinkTarget != nil {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { activeLinkTarget = nil } }

                    linkInputCard
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .ignoresSafeArea(.keyboard)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: activeLinkTarget != nil)
        }
        .modifier(NavBarHiddenModifier())
        .tabBarPresent(false)
        .task { await vm.load() }
        .alert("링크가 없습니다", isPresented: $showNoLinkAlert) {
            Button("확인", role: .cancel) {}
        }
        .alert("저장되었습니다", isPresented: $vm.saveSuccess) {
            Button("확인", role: .cancel) { dismiss() }
        }
        .alert("오류", isPresented: .init(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Scroll Body

    private var scrollBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topBackgroundSection
                if vm.isLoading {
                    loadingSection
                } else {
                    contentSection
                }
            }
        }
    }

    // MARK: - Top Background Section

    private var topBackgroundSection: some View {
        PromotionEditProfileHeader(
            vm: vm,
            onTapApplication: { openLink(.application, current: vm.applicationFormLink) },
            onTapYoutube: { openLink(.youtube, current: vm.youtubeLink) },
            onTapInstagram: { openLink(.instagram, current: vm.instagramLink) }
        )
    }

    private func openLink(_ target: LinkTarget, current: String) {
        linkDraft = current
        withAnimation { activeLinkTarget = target }
    }

    private func commitLink() {
        switch activeLinkTarget {
        case .youtube:     vm.youtubeLink = linkDraft
        case .instagram:   vm.instagramLink = linkDraft
        case .application: vm.applicationFormLink = linkDraft
        case nil: break
        }
        withAnimation { activeLinkTarget = nil }
    }

    private var linkInputCard: some View {
        let title: String = {
            switch activeLinkTarget {
            case .youtube:     return "YouTube 링크"
            case .instagram:   return "Instagram 링크"
            case .application: return "지원 링크"
            case nil:          return ""
            }
        }()

        return VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(AppTypography.notoSans(13, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button("완료") { commitLink() }
                    .font(AppTypography.notoSans(13, weight: .medium))
                    .foregroundStyle(AppColors.brand)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            TextField("https://", text: $linkDraft)
                .font(AppTypography.notoSans(12))
                .foregroundStyle(AppColors.textPrimary)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(AppColors.fieldFill)
                .clipShape(RoundedRectangle(cornerRadius: m.radius10))
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
        }
        .frame(width: 273)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            PromotionEditInfoSection(vm: vm)
                .padding(.top, m.space14)

            Rectangle()
                .fill(AppColors.separator)
                .frame(height: 1)
                .padding(.top, m.scale * 22)
                .padding(.horizontal, -m.space28)

            PromotionEditDescriptionField(vm: vm)
                .padding(.top, m.scale * 36)

            PromotionEditMediaSection(vm: vm)
                .padding(.top, m.scale * 22)

            saveButton
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, m.space24)
                .padding(.bottom, m.scale * 36)
        }
        .padding(.horizontal, m.space28)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            Task { await vm.save() }
        } label: {
            Group {
                if vm.isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("저장하기")
                        .font(AppTypography.notoSans(15))
                        .foregroundStyle(.white)
                }
            }
            // B-Promotion-6: 너비 152pt 고정, 중앙 정렬
            .frame(width: 152, height: m.scale * 54)
            .background(Color(hex: 0x353535))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(vm.isSaving)
    }

    // MARK: - Loading

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
}

// MARK: - Nav Bar Hidden

private struct NavBarHiddenModifier: ViewModifier {
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

#Preview("PromotionEditView") {
    NavigationStack {
        PromotionEditView(clubId: 1)
    }
}
