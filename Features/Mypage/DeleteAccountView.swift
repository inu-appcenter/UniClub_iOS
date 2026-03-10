//
//  DeleteAccountView.swift
//  UniClub
//
//  Created by 제욱 on 2/5/26.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.appMetrics) private var m
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = DeleteAccountViewModel()
    @State private var showConfirm: Bool = false

    // JSON 1/2 상태를 코드로 표현
    @State private var password: String = ""

    // 버튼 활성 조건 (JSON 2는 입력값 "12345"가 있음)
    private var isDeleteEnabled: Bool {
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        GeometryReader { geo in
            ScreenContainer(scroll: false) { _ in
                VStack(spacing: 0) {

                    header
                        .padding(.top, m.space8)

                    content
                        .padding(.top, 52)

                    Spacer(minLength: 0)

                    deleteButton
                        .padding(.bottom, geo.safeAreaInsets.bottom + 90)
                    // 🔥 여기 수정
                }
            }
        }
        .overlay {
                if vm.isLoading {
                    ZStack {
                        Color.black.opacity(0.08).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
            .alert("오류", isPresented: .constant(vm.errorMessage != nil)) {
                Button("확인") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("계정 삭제")
                .font(AppTypography.bodyStrong()) // JSON: NotoSansKR-Medium 15
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            // 우측은 비어있는 구조라 44로 맞춰 균형
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, m.space8)
        .frame(height: 44)
    }

    // MARK: - Content
    private var content: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("계정을 삭제하시겠습니까?")
                .font(AppTypography.bodyStrong()) // JSON: 14 medium
                .foregroundStyle(AppColors.textPrimary)

            Text("계정 삭제 시 활동 내역이 영구 삭제되며 복구가 불가능합니다. \n정말 삭제하시겠습니까?")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
                .padding(.top, 16)

            // 안내 문구(1번은 회색, 2번은 검정)
            Text("비밀번호를 입력해주세요.")
                .font(AppTypography.caption())
                .foregroundStyle(isDeleteEnabled ? AppColors.textPrimary : AppColors.textSecondary)
                .padding(.top, 44)

            passwordField
                .padding(.top, 10)

            dividerLine
                .padding(.top, 18)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 42) // JSON에서 본문/입력 영역이 중앙에 모여있음
    }

    private var passwordField: some View {
        // JSON에는 텍스트만 보이고(2번), 실제 입력 박스는 명확히 없어서
        // "비밀번호 입력"용 최소 뼈대만 제공 (선 + 텍스트 형태)
        SecureField("", text: $password)
            .font(AppTypography.caption())
            .foregroundStyle(AppColors.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .frame(height: 24)
            .frame(maxWidth: 180, alignment: .leading) // JSON 선 길이 184 근처
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(AppColors.textSecondary.opacity(0.6))
            .frame(height: 0.5)
            .frame(maxWidth: 184, alignment: .center) // JSON: 184px line
    }

    // MARK: - Delete Button
    private var deleteButton: some View {
        Button {
            showConfirm = true
        } label: {
            Text("네, 삭제하겠습니다.")
                .font(AppTypography.caption())
                .foregroundStyle(.white)
                .frame(width: 157, height: 30)
                .background(isDeleteEnabled ? Color(red: 1.0, green: 0.35, blue: 0.0) : Color(.systemGray3))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(!isDeleteEnabled || vm.isLoading)
        .alert("계정을 삭제할까요?", isPresented: $showConfirm) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                Task {
                    let ok = await vm.deleteAccount(password: password)
                    if ok {
                        dismiss() // 또는 루트 전환이라 dismiss 의미 없어질 수 있음
                    }
                }
            }
        } message: {
            Text("삭제 시 복구할 수 없습니다.")
        }
    }
}

#Preview {
    NavigationStack {
        DeleteAccountView()
    }
}
