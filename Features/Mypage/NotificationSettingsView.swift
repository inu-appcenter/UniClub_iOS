//
//  NotificationSettingsView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var m
    @StateObject private var fcm = FCMService.shared

    @State private var serverEnabled: Bool = false
    @State private var isTogglingServer: Bool = false

    private var isPushOn: Bool {
        let systemGranted = fcm.authorizationStatus == .authorized || fcm.authorizationStatus == .provisional
        return systemGranted && serverEnabled
    }

    var body: some View {
        ScreenContainer(scroll: false, topPadding: .none) { _ in
            VStack(spacing: 0) {
                AppPageHeader(onBack: { dismiss() }) {
                    Text("알림 설정")
                        .font(AppTypography.notoSans(15, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(.bottom, m.scale * 22)

                VStack(spacing: 0) {
                    content
                    Spacer()
                }
                .padding(.horizontal, m.space18)
            }
        }
        .navigationBarHidden(true)
        .task {
            await fcm.refreshAuthorizationStatus()
            await loadServerSetting()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await fcm.refreshAuthorizationStatus()
                await loadServerSetting()
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("질의응답, 관심 동아리, 총동아리연합회 소식 등 동아리의\n다양한 소식을 알려드릴게요.")
                .font(AppTypography.notoSans(11))
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, m.scale * 31)

            HStack(alignment: .center) {
                Text("앱 푸시 알림")
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: 0)

                UniToggle(isOn: isPushOn, onToggle: handleToggle)
                    .disabled(isTogglingServer)
            }
        }
    }

    private func loadServerSetting() async {
        do {
            serverEnabled = try await NotificationService.fetchSetting()
        } catch {
            // 실패 시 기본값 유지
        }
    }

    private func handleToggle() {
        switch fcm.authorizationStatus {
        case .notDetermined:
            Task { await fcm.requestPermission() }
        case .denied:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        default:
            // 시스템 권한 있으면 서버 설정 토글
            isTogglingServer = true
            Task {
                do {
                    try await NotificationService.toggleSetting()
                    serverEnabled.toggle()
                } catch {
                    // 실패 시 상태 유지
                }
                isTogglingServer = false
            }
        }
    }
}


// MARK: - Custom Toggle (49×30, knob 22×22)
private struct UniToggle: View {
    @Environment(\.appMetrics) private var m
    let isOn: Bool
    let onToggle: () -> Void

    private let w: CGFloat = 49
    private let h: CGFloat = 30
    private let knob: CGFloat = 22
    private let pad: CGFloat = 4

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.18)) {
                onToggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(trackColor)

                Circle()
                    .fill(AppColors.background)
                    .frame(width: knob, height: knob)
                    .offset(x: isOn ? (w/2 - knob/2 - pad) : -(w/2 - knob/2 - pad))
            }
            .frame(width: w, height: h)
            .accessibilityLabel("앱 푸시 알림")
            .accessibilityValue(isOn ? "켜짐" : "꺼짐")
        }
        .buttonStyle(.plain)
    }

    private var trackColor: Color {
        if isOn { return AppColors.brand }
        return AppColors.grey350  // #ACACAC
    }
}

#Preview("NotificationSettingsView") {
    NavigationStack {
        NotificationSettingsView()
    }
}
