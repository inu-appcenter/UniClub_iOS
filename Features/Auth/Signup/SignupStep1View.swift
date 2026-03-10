import SwiftUI

struct SignupStep1View: View {
    let onVerified: () -> Void   // ✅ “다음” 버튼에서만 호출되게 바꿈

    @EnvironmentObject private var vm: SignupFlowViewModel
    @Environment(\.appMetrics) private var m

    @State private var showAlert: Bool = false
    @State private var showMajorPicker: Bool = false

    // ✅ EnvironmentObject 접근 꼬임 방지
    private var model: SignupFlowViewModel { _vm.wrappedValue }

    // MARK: - UI Rules
    private var canTapVerify: Bool {
        let sid = model.studentId.trimmingCharacters(in: .whitespacesAndNewlines)
        return !model.isPortalVerified
        && !model.isLoading
        && !sid.isEmpty
        && !model.password.isEmpty
    }

    private var canTapNext: Bool {
        let name = model.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let majorCode = model.majorCode.trimmingCharacters(in: .whitespacesAndNewlines)

        return model.isPortalVerified
        && !model.isLoading
        && !name.isEmpty
        && !majorCode.isEmpty
    }

    var body: some View {
        ScreenContainer(scroll: true) { _ in
            ZStack {
                VStack(alignment: .leading, spacing: 16) {

                    Text("회원가입")
                        .font(AppTypography.title())
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, 12)

                    // ✅ 학번/비번: 인증 전까지 입력 가능, 인증 후 비활성(잠금)
                    field(title: "학번", text: Binding(
                        get: { model.studentId },
                        set: { model.studentId = $0 }
                    ), isSecure: false, keyboard: .numberPad)
                    .disabled(model.isPortalVerified)
                    .opacity(model.isPortalVerified ? 0.6 : 1)

                    field(title: "비밀번호", text: Binding(
                        get: { model.password },
                        set: { model.password = $0 }
                    ), isSecure: true, keyboard: .default)
                    .disabled(model.isPortalVerified)
                    .opacity(model.isPortalVerified ? 0.6 : 1)

                    // ✅ 이름/학과: 인증 전에는 비활성
                    field(title: "이름", text: Binding(
                        get: { model.name },
                        set: { model.name = $0 }
                    ), isSecure: false, keyboard: .default)
                    .disabled(!model.isPortalVerified)
                    .opacity(model.isPortalVerified ? 1 : 0.4)

                    majorPickerRow
                        .disabled(!model.isPortalVerified)
                        .opacity(model.isPortalVerified ? 1 : 0.4)

                    // ✅ 인증 완료 라벨
                    if model.isPortalVerified {
                        Text("✅ 재학생 확인 완료")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.brand)
                            .padding(.top, 2)
                    }

                    if !model.isPortalVerified {
                        Button {
                            Task {
                                let ok = await model.verifyStudent()
                                if !ok { showAlert = true }
                            }
                        } label: {
                            Text(model.isLoading ? "확인 중..." : "재학생 확인")
                                .font(AppTypography.bodyStrong())
                                .foregroundStyle(AppColors.onBrand)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.brand)
                                .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canTapVerify)
                        .opacity(canTapVerify ? 1 : 0.35)
                    } else {
                        Button {
                            onVerified()
                        } label: {
                            Text("다음")
                                .font(AppTypography.bodyStrong())
                                .foregroundStyle(AppColors.onBrand)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.brand)
                                .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canTapNext)
                        .opacity(canTapNext ? 1 : 0.35)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)

                // ✅ MajorPicker 연결
                MajorPickerSheetView(
                    isPresented: $showMajorPicker,
                    onSelectMajor: { item in
                        model.majorDisplay = item.display
                        model.majorCode = item.code
                    }
                )
            }
        }
        .onChange(of: model.errorMessage) { _, newValue in
            showAlert = (newValue != nil)
        }
        .alert("회원가입", isPresented: $showAlert) {
            Button("확인") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    // MARK: - Major Picker Row
    private var majorPickerRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("학과")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            Button {
                showMajorPicker = true
            } label: {
                HStack {
                    // ✅ 표시용은 majorDisplay만 사용
                    Text(!model.majorDisplay.isEmpty ? model.majorDisplay : "학과 선택")
                        .font(AppTypography.body())
                        .foregroundStyle(!model.majorDisplay.isEmpty ? AppColors.textPrimary : AppColors.textSecondary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(AppColors.fieldFill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Field
    private func field(title: String, text: Binding<String>, isSecure: Bool, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            if isSecure {
                SecureField("", text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(AppColors.fieldFill)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                TextField("", text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(AppColors.fieldFill)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
