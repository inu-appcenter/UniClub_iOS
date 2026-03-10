//
//  SignupStep2NicnameView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

/// Signup_6: 닉네임 입력 단계
/// - 다음 버튼은 닉네임이 비어있지 않으면 활성화
/// - 완료 시 상위에서 다음 플로우로 연결
struct SignupStep2NicknameView: View {
    @EnvironmentObject private var vm: SignupFlowViewModel

    let onBack: (() -> Void)?        // 필요 없으면 nil로
    let onComplete: () -> Void

    private var canGoNext: Bool {
        !vm.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !vm.isLoading
    }

    var body: some View {
        ScreenContainer(scroll: true) { m in
            VStack(alignment: .leading, spacing: 0) {

                // 상단 헤더 (뒤로/타이틀)
                HStack(spacing: m.space10) {
                    if let onBack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Spacer().frame(width: 44, height: 44)
                    }

                    Text("회원가입")
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer(minLength: 0)

                    Spacer().frame(width: 44, height: 44)
                }
                .padding(.top, m.space10)
                .padding(.bottom, m.space18)

                // 안내 문구
                Text("닉네임을 입력해주세요.")
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.bottom, m.space18)

                // 닉네임 입력
                UnderlineInput(
                    title: "닉네임",
                    text: $vm.nickname,
                    keyboard: .default
                )
                .padding(.bottom, m.space24)

                // 완료 버튼
                Button {
                    guard canGoNext else { return }
                    onComplete()
                } label: {
                    Text("완료")
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(canGoNext ? AppColors.onBrand : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, m.space12)
                        .background(canGoNext ? AppColors.brand : AppColors.fieldFill)
                        .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                        .overlay(
                            RoundedRectangle(cornerRadius: m.radius18)
                                .stroke(AppColors.border, lineWidth: m.hairline)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canGoNext)
                .opacity(canGoNext ? 1.0 : 0.65)

                Spacer(minLength: m.space24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}


// MARK: - Underline Input (SignupStep1View와 동일 스타일)
private struct UnderlineInput: View {
    @Environment(\.appMetrics) private var m

    let title: String
    @Binding var text: String
    let keyboard: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: m.space8) {
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            TextField("", text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

            Rectangle()
                .fill(AppColors.border)
                .frame(height: m.hairline)
        }
    }
}
