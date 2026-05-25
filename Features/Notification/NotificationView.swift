//
//  NotificationView.swift
//  UniClub

import SwiftUI

private enum NotificationTab {
    case unread, read
}

struct NotificationView: View {
    @Environment(\.appMetrics) private var m

    let onBack: () -> Void

    @StateObject private var vm = NotificationViewModel()
    @State private var selectedTab: NotificationTab = .unread

    private var current: [NotificationItem] { selectedTab == .unread ? vm.unread : vm.read }

    var body: some View {
        ScreenContainer(
            scroll: false,
            background: AppColors.backgroundTertiary,
            topPadding: .none,
            bottomPadding: .none
        ) { _ in
            VStack(spacing: 0) {
                header
                tabBar
                bulkActionRow
                content
            }
        }
        .navigationBarHidden(true)
        .task { await vm.load() }
    }

    // MARK: - Header

    private var header: some View {
        AppPageHeader(onBack: { onBack() }) {
            Text("알림")
                .font(AppTypography.notoSans(15, weight: .medium))
                .foregroundStyle(AppColors.grey800)
        }
    }

    // MARK: - Tab Bar (인디케이터가 텍스트 위)

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem("안읽은 알림", tab: .unread)
            tabItem("읽은 알림",   tab: .read)
        }
        .padding(.top, m.space8)
    }

    private func tabItem(_ label: String, tab: NotificationTab) -> some View {
        let isActive = selectedTab == tab

        return VStack(spacing: 0) {
            // 인디케이터가 위
            Rectangle()
                .fill(isActive ? AppColors.brand : AppColors.inactiveTab)
                .frame(height: 4)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) { selectedTab = tab }
            }) {
                Text(label)
                    .font(AppTypography.notoSans(11, weight: .medium))
                    .foregroundStyle(isActive ? AppColors.brand : AppColors.grey500)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 전체 읽음 / 전체 삭제 (탭바 아래 별도 행)

    private var bulkActionRow: some View {
        HStack {
            Spacer()
            Button(action: handleBulkAction) {
                Text(selectedTab == .unread ? "전체 읽음" : "전체 삭제")
                    .font(AppTypography.notoSans(11))
                    .foregroundStyle(current.isEmpty ? AppColors.grey300 : AppColors.brand)
            }
            .buttonStyle(.plain)
            .disabled(current.isEmpty)
        }
        .padding(.horizontal, m.space16)
        .frame(height: 36)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if current.isEmpty {
            Spacer()
            Text("알림이 없어요.")
                .font(AppTypography.notoSans(20))
                .foregroundStyle(AppColors.grey300)
            Spacer()
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: m.space16) {
                    ForEach(current) { item in
                        NotificationRowView(
                            item: item,
                            onAction: { handleAction(item) }
                        )
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await vm.delete(item: item) }
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                            .tint(AppColors.brand)
                        }
                    }
                }
                .padding(.vertical, m.space8)
            }
        }
    }

    // MARK: - Actions

    private func handleBulkAction() {
        if selectedTab == .unread {
            Task { await vm.markAllRead() }
        } else {
            Task { await vm.deleteAll(readOnly: true) }
        }
    }

    private func handleAction(_ item: NotificationItem) {
        Task { await vm.markRead(item: item) }
    }
}

#Preview("알림 - 안읽은 목록") {
    NotificationView(onBack: {})
        .environment(\.appMetrics, .make(for: CGSize(width: 390, height: 844)))
}

#Preview("알림 - 빈 화면") {
    var view = NotificationView(onBack: {})
    return view
        .environment(\.appMetrics, .make(for: CGSize(width: 390, height: 844)))
        .onAppear { }
}
