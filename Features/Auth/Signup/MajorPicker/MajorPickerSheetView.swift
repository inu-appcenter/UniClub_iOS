import SwiftUI

struct MajorPickerSheetView: View {
    @Environment(\.appMetrics) private var m

    @Binding var isPresented: Bool
    @State private var selectedTab: MajorTab = .undergrad

    let onSelectMajor: (MajorItem) -> Void

    enum MajorTab { case undergrad, graduate }

    var body: some View {
        if isPresented {
            ZStack(alignment: .bottom) {
                // Dim
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }

                // Sheet — ignoresSafeArea를 clipShape 이전에 적용해야 모서리 보임
                VStack(spacing: 0) {
                    tabBar
                    pairList
                }
                .background(AppColors.background)
                .ignoresSafeArea(edges: .bottom)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 50 * m.scale,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 50 * m.scale
                    )
                )
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.25), value: isPresented)
        }
    }

    // MARK: - Tab Bar
    // Figma: 학부생 x=38 y=35, 대학원생 x=220 y=35, 인디케이터 y=64 w=102 h=4

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem("학부생",   tab: .undergrad, leadingPad: 38 * m.scale)
            tabItem("대학원생", tab: .graduate,  leadingPad: 40 * m.scale)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 35 * m.scale)
    }

    private func tabItem(_ title: String, tab: MajorTab, leadingPad: CGFloat) -> some View {
        let isActive = selectedTab == tab
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { selectedTab = tab }
        } label: {
            VStack(alignment: .leading, spacing: 5 * m.scale) {
                Text(title)
                    .font(AppTypography.notoSans(14, weight: .semibold))
                    .foregroundStyle(isActive ? AppColors.brand : AppColors.grey300)

                // 고정 102pt 인디케이터
                Rectangle()
                    .fill(isActive ? AppColors.brand : AppColors.grey300)
                    .frame(width: 102 * m.scale, height: 4 * m.scale)
                    .clipShape(RoundedRectangle(cornerRadius: 2 * m.scale))
            }
            .padding(.leading, leadingPad)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pair List
    // Figma: 첫 섹션 y=115 (탭 인디케이터 아래 47pt)
    // 구분선: x=28 w=303 (좌우 28-29pt 여백)
    // 좌열 x=41, 우열 x=220, 각 w=123

    private var pairList: some View {
        let pairs = selectedTab == .undergrad
            ? MajorCatalog.undergradPairs
            : MajorCatalog.graduatePairs

        return ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(pairs.enumerated()), id: \.element.id) { idx, pair in
                    pairRow(pair)

                    if idx < pairs.count - 1 {
                        // Figma: x=28 w=303 #D9D9D9, 쌍 사이 25pt 위 / 24pt 아래
                        Rectangle()
                            .fill(Color(hex: 0xD9D9D9))
                            .frame(height: 1)
                            .padding(.horizontal, 28 * m.scale)
                            .padding(.top, 25 * m.scale)
                            .padding(.bottom, 24 * m.scale)
                    }
                }
            }
            // 첫 섹션: 탭 인디케이터 아래 47pt
            .padding(.top, 47 * m.scale)
            .padding(.bottom, m.space16)
        }
        .frame(maxHeight: 460 * m.scale)
    }

    private func pairRow(_ pair: MajorColumnPair) -> some View {
        // Figma: 좌열 x=41, 우열 x=220, 각 w=123, 사이 간격 56pt
        HStack(alignment: .top, spacing: 0) {
            sectionView(pair.left)
                .frame(width: 123 * m.scale, alignment: .leading)
                .padding(.leading, 41 * m.scale)

            Spacer()

            if !pair.right.items.isEmpty {
                sectionView(pair.right)
                    .frame(width: 123 * m.scale, alignment: .leading)
                    .padding(.trailing, 17 * m.scale)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionView(_ section: MajorSection) -> some View {
        VStack(alignment: .leading, spacing: 11 * m.scale) {
            Text(section.title)
                .font(AppTypography.notoSans(14, weight: .medium))
                .foregroundStyle(AppColors.brand)

            ForEach(section.items) { item in
                Button {
                    onSelectMajor(item)
                    isPresented = false
                } label: {
                    Text(item.display)
                        .font(AppTypography.notoSans(14))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
