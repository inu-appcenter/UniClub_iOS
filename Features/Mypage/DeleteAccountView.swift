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
    @State private var password: String = ""
    @State private var showDeleteSuccess: Bool = false

    private var isDeleteEnabled: Bool {
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var secondaryTextColor: Color {
        Color(red: 0.490, green: 0.490, blue: 0.490)
    }

    var body: some View {
        ScreenContainer(
            scroll: false,
            topPadding: .none,
            bottomPadding: .default
        ) { _ in
            VStack(spacing: 0) {
                AppPageHeader(onBack: { dismiss() }) {
                    Text("계정 삭제")
                        .font(AppTypography.notoSans(15, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                }

                content
                    .padding(.top, m.scale * 33)
                    .padding(.leading, m.space24)

                deleteButton
                    .padding(.top, m.scale * 50)
                    .padding(.leading, m.space24)

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if vm.isLoading {
                ZStack {
                    AppColors.grey800.opacity(0.08).ignoresSafeArea()
                    ProgressView()
                }
            }
        }
        .alert("계정이 삭제되었습니다", isPresented: $showDeleteSuccess) {
            Button("확인") {
                Task { await MyAuthStore.shared.signOut() }
            }
        }
        .alert(
            "오류",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { newValue in
                    if !newValue {
                        vm.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인") {
                vm.errorMessage = nil
            }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Content
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("계정을 삭제하시겠습니까?")
                .font(AppTypography.notoSans(14 * m.scale, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Text("계정 삭제 시 활동 내역이 영구 삭제되며 복구가 불가능합니다. \n정말 삭제하시겠습니까?")
                .font(AppTypography.notoSans(11 * m.scale))
                .foregroundStyle(secondaryTextColor)
                .multilineTextAlignment(.leading)
                .lineSpacing(m.space4)
                .padding(.top, m.space4)

            Text("비밀번호를 입력해주세요.")
                .font(AppTypography.notoSans(11 * m.scale))
                .foregroundStyle(isDeleteEnabled ? AppColors.textPrimary : secondaryTextColor)
                .padding(.top, m.space44)

            passwordField
                .padding(.top, 11 * m.scale)

            dividerLine
                .padding(.top, 3 * m.scale)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var passwordField: some View {
        SecureField("", text: $password)
            .font(AppTypography.notoSans(11 * m.scale))
            .foregroundStyle(AppColors.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.password)
            .frame(width: 184 * m.scale, height: 17 * m.scale, alignment: .leading)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(isDeleteEnabled ? AppColors.grey800 : secondaryTextColor)
            .frame(width: 184 * m.scale, height: 0.5)
    }

    // MARK: - Delete Button
    private var deleteButton: some View {
        Button {
            Task {
                let ok = await vm.deleteAccount(password: password)
                if ok {
                    showDeleteSuccess = true
                }
            }
        } label: {
            Text("네, 삭제하겠습니다.")
                .font(AppTypography.notoSans(11 * m.scale, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 157 * m.scale, height: 30 * m.scale)
                .background(
                    isDeleteEnabled
                    ? Color(red: 1.0, green: 0.35, blue: 0.0)
                    : Color(red: 0.75, green: 0.75, blue: 0.75)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14 * m.scale))
        }
        .buttonStyle(.plain)
        .disabled(!isDeleteEnabled || vm.isLoading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        DeleteAccountView()
    }
}
