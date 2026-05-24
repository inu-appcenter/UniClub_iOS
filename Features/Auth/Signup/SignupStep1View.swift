import SwiftUI

struct SignupStep1View: View {
    let onBack: () -> Void
    let onVerified: () -> Void

    @Environment(\.appMetrics) private var m
    @EnvironmentObject private var model: SignupFlowViewModel
    @State private var showMajorPicker: Bool = false

    private var canTapVerify: Bool {
        !model.isPortalVerified
        && !model.isLoading
        && !model.studentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !model.password.isEmpty
    }

    private var canTapNext: Bool {
        model.isPortalVerified
        && !model.isLoading
        && !model.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !model.majorCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScreenContainer(
            scroll: true,
            showsIndicators: false,
            topPadding: .none,
            bottomPadding: .none,
            horizontalPadding: .custom(31 * m.scale)
        ) { _ in
            VStack(alignment: .leading, spacing: 0) {

                AppPageHeader(onBack: { onBack() }) { }

                // 회원가입 헤더 (뒤로가기 하단 ~ 헤더: 43pt)
                Text("회원가입")
                    .font(AppTypography.notoSans(32 * m.scale, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, 43 * m.scale)

                // 포털 안내 배지 (Figma y=165 → 헤더 하단 y=158 기준 7pt)
                portalBadge(scale: m.scale)
                    .padding(.top, 7 * m.scale)

                Color.clear.frame(height: 42 * m.scale)

                signupField(
                    label: "학번을 입력해주세요.",
                    text: Binding(get: { model.studentId }, set: { model.studentId = $0 }),
                    isSecure: false,
                    isActive: !model.isPortalVerified,
                    scale: m.scale
                )
                .disabled(model.isPortalVerified)

                Color.clear.frame(height: m.space20)

                signupField(
                    label: "비밀번호를 입력해주세요.",
                    text: Binding(get: { model.password }, set: { model.password = $0 }),
                    isSecure: true,
                    isActive: !model.isPortalVerified,
                    scale: m.scale
                )
                .disabled(model.isPortalVerified)

                if model.isPortalVerified {
                    Text("재학생 확인이 완료되었습니다.")
                        .font(AppTypography.notoSans(11 * m.scale, weight: .medium))
                        .foregroundStyle(AppColors.brand)
                        .padding(.top, m.space16)
                    Color.clear.frame(height: 48 * m.scale)
                } else if model.errorMessage != nil {
                    errorTooltip(scale: m.scale)
                        .padding(.top, 26 * m.scale)
                    Color.clear.frame(height: 29 * m.scale)
                } else {
                    Color.clear.frame(height: 81 * m.scale)
                }

                signupField(
                    label: "이름을 입력해주세요.",
                    text: Binding(get: { model.name }, set: { model.name = $0 }),
                    isSecure: false,
                    isActive: model.isPortalVerified,
                    scale: m.scale
                )
                .disabled(!model.isPortalVerified)

                Color.clear.frame(height: m.space20)

                majorPickerRow(scale: m.scale)
                    .disabled(!model.isPortalVerified)

                Color.clear.frame(height: 117 * m.scale)

                actionButton(scale: m.scale)
                    .frame(maxWidth: .infinity, alignment: .center)

                Color.clear.frame(height: 40 * m.scale)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        }
        .overlay {
            MajorPickerSheetView(
                isPresented: $showMajorPicker,
                onSelectMajor: { item in
                    model.majorDisplay = item.display
                    model.majorCode = item.code
                }
            )
        }
        .overlay {
            // B-Signup-1: 이미 가입된 회원 모달
            if model.isAlreadyRegistered {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        Text("이미 가입된 회원입니다.")
                            .font(AppTypography.notoSans(16 * m.scale, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.top, m.space28)
                            .padding(.horizontal, m.space20)

                        Spacer(minLength: m.space20)

                        Button {
                            model.isAlreadyRegistered = false
                        } label: {
                            Text("확인")
                                .font(AppTypography.notoSans(14 * m.scale, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48 * m.scale)
                                .background(AppColors.brand)
                                .clipShape(RoundedRectangle(cornerRadius: 0))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 270 * m.scale)
                    .background(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 20 * m.scale))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
            }
        }
    }

    // MARK: - Portal Badge
    // Figma: #FF5900 bg, r=13, 184x26, icon 16x16 at x=7, text at x=31
    private func portalBadge(scale: CGFloat) -> some View {
        HStack(spacing: 8 * scale) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 12 * scale))
                .frame(width: 16 * scale, height: 16 * scale)
            Text("학교 포털 계정을 입력해주세요.")
                .font(AppTypography.notoSans(11 * scale))
        }
        .foregroundStyle(AppColors.background)
        .padding(.leading, 7 * scale)
        .frame(width: 184 * scale, height: 26 * scale, alignment: .leading)
        .background(AppColors.brand)
        .clipShape(RoundedRectangle(cornerRadius: 13 * scale))
    }

    // MARK: - Signup Field (underline style)
    // Figma: label 14pt Regular, input below, underline width 184pt
    private func signupField(
        label: String,
        text: Binding<String>,
        isSecure: Bool,
        isActive: Bool,
        scale: CGFloat
    ) -> some View {
        let labelColor: Color = isActive ? AppColors.textPrimary : AppColors.grey400
        let lineColor: Color = isActive ? AppColors.grey800 : AppColors.grey400

        return VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(AppTypography.notoSans(14 * scale))
                .foregroundStyle(labelColor)

            Color.clear.frame(height: 8 * scale)

            Group {
                if isSecure {
                    SecureField("", text: text)
                } else {
                    TextField("", text: text)
                }
            }
            .font(AppTypography.notoSans(14 * scale))
            .foregroundStyle(AppColors.textPrimary)
            .frame(height: 24 * scale)

            Color.clear.frame(height: 1 * scale)

            Rectangle()
                .fill(lineColor)
                .frame(width: 184 * scale, height: 1 * scale)
        }
        .frame(width: 184 * scale, alignment: .leading)
    }

    // MARK: - Error Tooltip
    // Figma Frame 178: #000000 bg, r=13, 193x26, 11pt white text
    private func errorTooltip(scale: CGFloat) -> some View {
        Text("학번과 비밀번호를 확인해주세요.")
            .font(AppTypography.notoSans(11 * scale))
            .foregroundStyle(AppColors.background)
            .padding(.horizontal, 8 * scale)
            .frame(width: 193 * scale, height: 26 * scale, alignment: .leading)
            .background(AppColors.grey800)
            .clipShape(RoundedRectangle(cornerRadius: 13 * scale))
    }

    // MARK: - Major Picker Row
    // Figma: 14pt Regular text, chevron 12x6 at right, no underline
    private func majorPickerRow(scale: CGFloat) -> some View {
        let isActive = model.isPortalVerified
        let labelColor: Color = isActive ? AppColors.textPrimary : AppColors.grey400

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                if isActive { showMajorPicker = true }
            } label: {
                HStack(spacing: 0) {
                    Text(model.majorDisplay.isEmpty ? "학과를 선택해주세요." : model.majorDisplay)
                        .font(AppTypography.notoSans(14 * scale))
                        .foregroundStyle(labelColor)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 9 * scale, weight: .regular))
                        .foregroundStyle(AppColors.iconNeutral)
                        .frame(width: 12 * scale, height: 6 * scale)
                }
                .frame(width: 184 * scale)
            }
            .buttonStyle(.plain)

            Color.clear.frame(height: 8 * scale)

            Rectangle()
                .fill(isActive ? AppColors.grey800 : AppColors.grey400)
                .frame(width: 184 * scale, height: 1 * scale)
        }
        .frame(width: 184 * scale, alignment: .leading)
    }

    // MARK: - Action Button
    // 재학생 확인: 173x51, r=45 / 다음: 132x51, r=45
    // active=#000000, disabled=#D2D2D2(grey300)
    @ViewBuilder
    private func actionButton(scale: CGFloat) -> some View {
        if model.isPortalVerified {
            Button {
                guard canTapNext else { return }
                onVerified()
            } label: {
                Text("다음")
                    .font(AppTypography.notoSans(14 * scale))
                    .foregroundStyle(AppColors.background)
                    .frame(width: 132 * scale, height: 51 * scale)
                    .background(canTapNext ? AppColors.grey800 : AppColors.grey300)
                    .clipShape(RoundedRectangle(cornerRadius: 45 * scale))
                    .buttonShadow(.small)
            }
            .buttonStyle(.plain)
            .disabled(!canTapNext)
        } else {
            Button {
                Task {
                    _ = await model.verifyStudent()
                }
            } label: {
                Text(model.isLoading ? "확인 중..." : "재학생 확인")
                    .font(AppTypography.notoSans(14 * scale))
                    .foregroundStyle(AppColors.background)
                    .frame(width: 173 * scale, height: 51 * scale)
                    .background(canTapVerify ? AppColors.grey800 : AppColors.grey300)
                    .clipShape(RoundedRectangle(cornerRadius: 45 * scale))
                    .buttonShadow(.small)
            }
            .buttonStyle(.plain)
            .disabled(!canTapVerify)
        }
    }
}
