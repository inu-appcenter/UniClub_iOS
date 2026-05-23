//
//  SignupStep3View.swift
//  UniClub

import SwiftUI

struct SignupStep3TermsView: View {
    let onBack: () -> Void
    let onNext: () -> Void

    @EnvironmentObject private var vm: SignupFlowViewModel
    @Environment(\.appMetrics) private var m

    @State private var showAlert: Bool = false

    /// Figma: 필수 체크 시 활성화
    private var canGoNext: Bool { vm.agreePrivacy && !vm.isLoading }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    AppPageHeader(onBack: { onBack() }) { }

                    // 로고 (Figma x=31, w=188)
                    Image("logo_signup_uniclub")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 188 * m.scale)
                        .padding(.top, 12 * m.scale)
                        .padding(.leading, 10 * m.scale)

                    // 타이틀 (Figma x=31, 32pt Bold)
                    Text("이용약관")
                        .font(AppTypography.notoSans(32 * m.scale, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, 8 * m.scale)
                        .padding(.leading, 10 * m.scale)

                    // 약관 텍스트 (Figma x=34, 14pt)
                    Text(termsText)
                        .font(AppTypography.notoSans(14 * m.scale))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 19 * m.scale)
                        .padding(.leading, 13 * m.scale)
                        .padding(.trailing, 13 * m.scale)

                    // 동의 섹션 제목 (Figma 20pt Bold)
                    Text("이용약관에 동의해 주세요.")
                        .font(AppTypography.notoSans(20 * m.scale, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, 44 * m.scale)
                        .padding(.leading, 13 * m.scale)

                    // 필수 동의 box (C-3: 29pt)
                    checkboxBox(
                        "(필수) 개인정보 수집 및 이용에 동의합니다.",
                        isOn: $vm.agreePrivacy
                    )
                    .padding(.top, 29 * m.scale)  // already correct

                    // 선택 동의 box
                    checkboxBox(
                        "(선택) 마케팅 및 광고 활용에 동의합니다.",
                        isOn: $vm.agreeMarketing
                    )
                    .padding(.top, 7 * m.scale)

                    // 다음 버튼
                    Button {
                        guard canGoNext else { return }
                        Task {
                            let ok = await vm.register()
                            if ok { onNext() } else { showAlert = true }
                        }
                    } label: {
                        Text(vm.isLoading ? "처리 중..." : "다음")
                            .font(AppTypography.notoSans(14 * m.scale))
                            .foregroundStyle(.white)
                            .frame(width: 132 * m.scale, height: 51 * m.scale)
                            .background(canGoNext ? AppColors.brand : AppColors.grey300)
                            .clipShape(RoundedRectangle(cornerRadius: 45 * m.scale))
                            .buttonShadow(.small)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canGoNext || vm.isLoading)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 35 * m.scale)
                    .padding(.bottom, 64 * m.scale)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 21 * m.scale)
            }
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

    // MARK: - 체크박스 행 (Figma: 319×49, r=15, 0.5pt stroke)

    private func checkboxBox(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 3 * m.scale) {
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4 * m.scale)
                        .stroke(
                            isOn.wrappedValue ? AppColors.brand : AppColors.grey300,
                            lineWidth: 2.0
                        )
                        .frame(width: 24 * m.scale, height: 24 * m.scale)

                    if isOn.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12 * m.scale, weight: .bold))
                            .foregroundStyle(AppColors.brand)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(title)
                .font(AppTypography.notoSans(13 * m.scale, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.leading, 13 * m.scale)
        .padding(.trailing, 14 * m.scale)
        .frame(maxWidth: .infinity)
        .frame(height: 49 * m.scale)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.grey300, lineWidth: 0.5)
        )
    }

    // MARK: - 약관 텍스트

    private let termsText = """
    회원가입 시 개인정보 수집 및 이용 동의

    개인정보 수집 및 이용 동의서

    앱(이하 "서비스")는 고객님의 개인정보 보호를 중요하게 생각하며, 관련 법령을 준수하고 있습니다. 서비스 회원가입을 위해 아래와 같이 개인정보 수집 및 이용에 동의해 주시기 바랍니다.

    1. 수집하는 개인정보 항목
    - 필수항목: 이름, 연락처(휴대폰 번호), 이메일, 생년월일, 성별, 서비스 이용 기록
    - 선택항목: 프로필 사진

    2. 개인정보의 수집 및 이용 목적
    - 회원관리: 서비스 이용을 위한 회원 인증 및 본인 확인
    - 마케팅 및 광고: 서비스 이용 통계 분석 및 이벤트 정보 제공 (선택적 동의)

    3. 개인정보 보유 및 이용 기간
    - 서비스 탈퇴 시까지 보유하며, 탈퇴 후 즉시 삭제됩니다. 단, 관련 법령에 따라 일정 기간 보관이 필요할 경우, 해당 기간 동안 저장됩니다.

    4. 동의 거부 권리 및 동의 거부 시 불이익
    - 회원가입을 위한 필수항목에 대한 동의를 거부하실 수 있으나, 이 경우 회원가입 및 서비스 이용이 제한될 수 있습니다.
    """
}
