//
//  SignupRootView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

struct SignupRootView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: SignupStep = .step1

    var body: some View {
        ScreenContainer(scroll: true) { m in
            VStack(alignment: .leading, spacing: 0) {

                // 상단 헤더 (회원가입 / 뒤로)
                HStack(spacing: m.space10) {
                    IconButton(systemName: "chevron.left") { dismiss() }
                    Text("회원가입")
                        .font(AppTypography.title())
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer(minLength: 0)
                }
                .padding(.top, m.space10)
                .padding(.bottom, m.space18)

                // 현재 Step 화면
                Group {
                    switch step {
                    case .step1:
                        SignupStep1View(onVerified: {
                            // 일단 뼈대 단계: 재학생 확인 성공하면 다음 단계로 이동
                            goNext()
                        })
                    case .step2:
                        SignupStepPlaceholder(title: "Signup_2")
                    case .step3:
                        SignupStepPlaceholder(title: "Signup_3")
                    case .step3_1:
                        SignupStepPlaceholder(title: "Signup_3_1")
                    case .step4:
                        SignupStepPlaceholder(title: "Signup_4")
                    case .step5:
                        SignupStepPlaceholder(title: "Signup_5")
                    case .step6:
                        SignupStepPlaceholder(title: "Signup_6")
                    case .collectMajor1:
                        SignupStepPlaceholder(title: "Signup_Collectmajor_1")
                    case .collectMajor2:
                        SignupStepPlaceholder(title: "Signup_Collectmajor_2")
                    case .terms7:
                        SignupStepPlaceholder(title: "Signup_7 (이용약관)")
                    case .terms8:
                        SignupStepPlaceholder(title: "Signup_8 (이용약관)")
                    }
                }
                .padding(.bottom, m.space18)

                // 하단 버튼 (이전/다음)
                HStack(spacing: m.space12) {
                    Button {
                        goPrev()
                    } label: {
                        Text("이전")
                            .font(AppTypography.bodyStrong())
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, m.space12)
                            .background(AppColors.cardFill)
                            .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                            .overlay(
                                RoundedRectangle(cornerRadius: m.radius18)
                                    .stroke(AppColors.border, lineWidth: m.hairline)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        goNext()
                    } label: {
                        Text("다음")
                            .font(AppTypography.bodyStrong())
                            .foregroundStyle(AppColors.onBrand) // 없으면 Color.white로 바꿔도 됨
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, m.space12)
                            .background(AppColors.brand)
                            .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: m.space24)
            }
        }
        .navigationBarHidden(true)
    }

    // 단계 이동: 지금은 순서대로만 (나중에 JSON 흐름 정확해지면 수정)
    private func goPrev() {
        let all: [SignupStep] = [.step1,.step2,.step3,.step3_1,.step4,.step5,.step6,.collectMajor1,.collectMajor2,.terms7,.terms8]
        guard let idx = all.firstIndex(of: step), idx > 0 else { return }
        step = all[idx - 1]
    }

    private func goNext() {
        let all: [SignupStep] = [.step1,.step2,.step3,.step3_1,.step4,.step5,.step6,.collectMajor1,.collectMajor2,.terms7,.terms8]
        guard let idx = all.firstIndex(of: step), idx < all.count - 1 else { return }
        step = all[idx + 1]
    }
}

private struct SignupStepPlaceholder: View {
    let title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTypography.bodyStrong())
            Text("여기는 JSON 기반으로 한 단계씩 실제 UI로 교체할 영역입니다.")
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview("SignupRootView") {
    SignupRootView()
}
