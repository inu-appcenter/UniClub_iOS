//
//  SignupStep2NicnameView.swift
//  UniClub

import SwiftUI

struct SignupStep2NicknameView: View {
    @EnvironmentObject private var vm: SignupFlowViewModel
    @Environment(\.appMetrics) private var m

    let onBack: (() -> Void)?
    let onComplete: () -> Void

    private var canGoNext: Bool {
        !vm.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !vm.isLoading
    }

    var body: some View {
        ScreenContainer(
            scroll: false,
            topPadding: .none,
            bottomPadding: .none,
            horizontalPadding: .custom(31 * m.scale)
        ) { _ in
            VStack(alignment: .leading, spacing: 0) {

                AppPageHeader(onBack: onBack) { }

                Text("회원가입")
                    .font(AppTypography.notoSans(32 * m.scale, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, 17 * m.scale)

                Text("닉네임을 입력해주세요.")
                    .font(AppTypography.notoSans(14 * m.scale))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, 22 * m.scale)

                TextField("", text: $vm.nickname)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(AppTypography.notoSans(14 * m.scale))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 184 * m.scale)
                    .padding(.top, m.space8)

                Rectangle()
                    .fill(AppColors.grey800)
                    .frame(width: 184 * m.scale, height: 1 * m.scale)
                    .padding(.top, m.space8)

                Spacer(minLength: 0)

                Button {
                    guard canGoNext else { return }
                    onComplete()
                } label: {
                    Text("다음")
                        .font(AppTypography.notoSans(14 * m.scale))
                        .foregroundStyle(.white)
                        .frame(width: 132 * m.scale, height: 51 * m.scale)
                        .background(canGoNext ? AppColors.grey800 : AppColors.grey300)
                        .clipShape(RoundedRectangle(cornerRadius: 45 * m.scale))
                        .buttonShadow(.small)
                }
                .buttonStyle(.plain)
                .disabled(!canGoNext)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 48 * m.scale)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        }
    }
}
