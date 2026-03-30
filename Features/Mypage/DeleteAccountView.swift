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
                header
                    .padding(.top, m.space8)

                content
                    .padding(.top, 52 * m.scale)

                deleteButton
                    .padding(.top, 50 * m.scale)

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.08).ignoresSafeArea()
                    ProgressView()
                }
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

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18 * m.scale, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44 * m.scale, height: 44 * m.scale)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("계정 삭제")
                .font(.system(size: 15 * m.scale, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 44 * m.scale, height: 44 * m.scale)
        }
        .padding(.horizontal, m.space8)
        .frame(height: 44 * m.scale)
    }

    // MARK: - Content
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("계정을 삭제하시겠습니까?")
                .font(.system(size: 14 * m.scale, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Text("계정 삭제 시 활동 내역이 영구 삭제되며 복구가 불가능합니다. \n정말 삭제하시겠습니까?")
                .font(.system(size: 11 * m.scale, weight: .regular))
                .foregroundStyle(secondaryTextColor)
                .multilineTextAlignment(.leading)
                .lineSpacing(4 * m.scale)
                .padding(.top, 16 * m.scale)

            Text("비밀번호를 입력해주세요.")
                .font(.system(size: 11 * m.scale, weight: .regular))
                .foregroundStyle(isDeleteEnabled ? AppColors.textPrimary : secondaryTextColor)
                .padding(.top, 53 * m.scale)

            passwordField
                .padding(.top, 11 * m.scale)

            dividerLine
                .padding(.top, 3 * m.scale)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var passwordField: some View {
        SecureField("", text: $password)
            .font(.system(size: 11 * m.scale, weight: .regular))
            .foregroundStyle(AppColors.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.password)
            .frame(width: 184 * m.scale, height: 17 * m.scale, alignment: .leading)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(isDeleteEnabled ? Color.black : secondaryTextColor)
            .frame(width: 184 * m.scale, height: 0.5)
    }

    // MARK: - Delete Button
    private var deleteButton: some View {
        Button {
            Task {
                let ok = await vm.deleteAccount(password: password)
                if ok {
                    dismiss()
                }
            }
        } label: {
            Text("네, 삭제하겠습니다.")
                .font(.system(size: 11 * m.scale, weight: .medium))
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
