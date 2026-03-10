//
//  NotificationSettingsView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var m

    // ✅ JSON _1(off) / _2(on) 차이는 이 상태값 하나
    @State private var isPushOn: Bool = false

    var body: some View {
        ScreenContainer(scroll: false) { _ in
            ZStack(alignment: .top) {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.top, 39)      // 상태바 아래 여백 느낌(피그마 상단 구성에 맞춤)
                        .padding(.bottom, 52)   // 타이틀~콘텐츠 간격 느낌

                    content
                        .padding(.horizontal, 36) // 텍스트/토글이 가운데 쪽에 모이는 느낌
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        ZStack {
            // 중앙 타이틀
            Text("알림 설정")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            // 왼쪽 뒤로가기(피그마 Vector)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 설명문(피그마에 있는 긴 회색 안내문)
            Text("질의응답, 관심 동아리, 총동아리연합회 소식 등 동아리의 다양한 소식을 알려드릴게요.")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 61)

            // “앱 푸시 알림” + 토글
            HStack(alignment: .center) {
                Text("앱 푸시 알림")
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: 0)

                UniToggle(isOn: $isPushOn)
            }
        }
    }
}


// MARK: - Custom Toggle (49×30, knob 22×22)
private struct UniToggle: View {
    @Environment(\.appMetrics) private var m
    @Binding var isOn: Bool

    private let w: CGFloat = 49
    private let h: CGFloat = 30
    private let knob: CGFloat = 22
    private let pad: CGFloat = 4

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.18)) {
                isOn.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(trackColor)

                Circle()
                    .fill(Color.white)
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
        // JSON 기준: OFF 회색 / ON 주황
        // ✅ AppColors.brand가 주황이면 그대로 사용됨
        if isOn { return AppColors.brand }
        return Color(white: 0.678) // 피그마의 회색(대략)과 유사
    }
}

#Preview("NotificationSettingsView") {
    NavigationStack {
        NotificationSettingsView()
    }
}
