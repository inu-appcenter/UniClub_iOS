import SwiftUI
import PhotosUI

struct PromotionEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var m
    @StateObject private var vm: PromotionEditViewModel

    @State private var scrollOffset: CGFloat = 0
    @State private var showNoLinkAlert = false

    @State private var showYoutubeSheet = false
    @State private var showInstagramSheet = false
    @State private var showApplicationSheet = false


    private let scrollSpace = "edit.scroll"
    private var topBackgroundHeight: CGFloat { m.scale * 276 }
    private var backgroundImageHeight: CGFloat { m.scale * 209 }
    private var stickyHeaderVisible: Bool { scrollOffset >= topBackgroundHeight - m.controlHeight44 }

    init(clubId: Int) {
        _vm = StateObject(wrappedValue: PromotionEditViewModel(clubId: clubId))
    }

    var body: some View {
        ScreenContainer(scroll: false, background: AppColors.backgroundTertiary, topPadding: .none, bottomPadding: .none) { _ in
            ZStack(alignment: .top) {
                scrollBody
                floatingTopBar
                    .opacity(stickyHeaderVisible ? 0 : 1)
                    .allowsHitTesting(!stickyHeaderVisible)
                if stickyHeaderVisible {
                    stickyHeader
                }
            }
            .animation(.easeInOut(duration: 0.15), value: stickyHeaderVisible)
            .padding(.horizontal, -m.horizontalPadding)
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
        .sheet(isPresented: $showYoutubeSheet) {
            LinkInputSheet(title: "YouTube 링크", url: $vm.youtubeLink)
        }
        .sheet(isPresented: $showInstagramSheet) {
            LinkInputSheet(title: "Instagram 링크", url: $vm.instagramLink)
        }
        .sheet(isPresented: $showApplicationSheet) {
            LinkInputSheet(title: "지원 링크", url: $vm.applicationFormLink)
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
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: EditScrollOffsetKey.self,
                        value: proxy.frame(in: .named(scrollSpace)).minY
                    )
                }
            )
        }
        .coordinateSpace(name: scrollSpace)
        .onPreferenceChange(EditScrollOffsetKey.self) { scrollOffset = max(0, -$0) }
    }

    // MARK: - Top Background Section

    private var topBackgroundSection: some View {
        PromotionEditProfileHeader(
            vm: vm,
            onTapApplication: { showApplicationSheet = true },
            onTapYoutube: { showYoutubeSheet = true },
            onTapInstagram: { showInstagramSheet = true }
        )
    }

    // MARK: - Floating Top Bar

    private var floatingTopBar: some View {
        PromotionEditFloatingTopBar(onDismiss: { dismiss() })
    }

    // MARK: - Sticky Header

    private var stickyHeader: some View {
        PromotionEditStickyHeader(vm: vm, onDismiss: { dismiss() })
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
                .padding(.horizontal, -m.space20)

            PromotionEditDescriptionField(vm: vm)
                .padding(.top, m.scale * 36)

            PromotionEditMediaSection(vm: vm)
                .padding(.top, m.scale * 22)

            saveButton
                .padding(.top, m.space24)
                .padding(.bottom, m.scale * 36)
        }
        .padding(.horizontal, m.space20)
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
            .frame(maxWidth: .infinity)
            .frame(height: m.scale * 54)
            .background(AppColors.grey700)
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

// MARK: - Scroll Offset Key

private struct EditScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
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
