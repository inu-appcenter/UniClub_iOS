//
//  SignupStep3View.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

struct SignupStep3TermsView: View {
    let onBack: () -> Void
    let onNext: () -> Void

    @EnvironmentObject private var vm: SignupFlowViewModel
    @Environment(\.appMetrics) private var m

    @State private var showAlert: Bool = false

    var body: some View {
        ScreenContainer(scroll: true) { _ in
            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("약관 동의")
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()
                    // 균형용
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.top, 12)

                toggleRow(
                    "개인정보 처리방침 동의 (필수)",
                    isOn: Binding(
                        get: { vm.agreePrivacy },
                        set: { vm.agreePrivacy = $0 }
                    )
                )

                toggleRow(
                    "마케팅 정보 수신 동의 (선택)",
                    isOn: Binding(
                        get: { vm.agreeMarketing },
                        set: { vm.agreeMarketing = $0 }
                    )
                )

                Button {
                    Task {
                        let ok = await vm.register()
                        if ok {
                            onNext()
                        } else {
                            showAlert = true
                        }
                    }
                } label: {
                    Text(vm.isLoading ? "처리 중..." : "가입 완료")
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(AppColors.onBrand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.brand)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
                .disabled(vm.isLoading)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: vm.errorMessage) { _, newValue in
            showAlert = (newValue != nil)
        }
        .alert("회원가입", isPresented: $showAlert) {
            Button("확인") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
        }
        .toggleStyle(SwitchToggleStyle(tint: AppColors.brand))
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(AppColors.fieldFill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
