import SwiftUI

struct LoginView: View {
    let onLogin: (_ studentId: String, _ password: String) -> Void
    let onTapSignup: () -> Void

    @Environment(\.appMetrics) private var m

    @State private var studentId: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                Image("logo_uniclub")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 188 * m.scale, alignment: .leading)
                    .padding(.top, 75 * m.scale)
                    .padding(.leading, 39 * m.scale)
                    .accessibilityLabel("UniClub 로고")
                Spacer(minLength: 276 * m.scale)

                // 입력 섹션 (x = 37, width = 294)
                VStack(alignment: .leading, spacing: 0) {
                    UnderlineField(
                        title: "학번",
                        text: $studentId,
                        isSecure: false,
                        trailingIconSystemName: nil,
                        onTapTrailing: nil,
                        scale: m.scale
                    )
                    .padding(.bottom, 53 * m.scale)

                    UnderlineField(
                        title: "비밀번호",
                        text: $password,
                        isSecure: !showPassword,
                        trailingIconSystemName: showPassword ? "eye" : "eye.slash",
                        onTapTrailing: { showPassword.toggle() },
                        scale: m.scale,
                        onFocusChange: { focused in
                            if focused {
                                withAnimation {
                                    proxy.scrollTo("passwordField", anchor: .bottom)
                                }
                            }
                        }
                    )
                    .id("passwordField")
                }
                .frame(width: 294 * m.scale, alignment: .leading)
                .padding(.leading, 37 * m.scale)

                Spacer(minLength: 52 * m.scale)

                    Button {
                        if studentId.isEmpty || password.isEmpty {
                            errorMessage = "학번과 비밀번호를 입력해주세요."
                            return
                        }
                        errorMessage = nil
                        onLogin(studentId, password)
                    } label: {
                        Text("로그인")
                            .font(AppTypography.notoSans(14 * m.scale))
                            .foregroundStyle(AppColors.background)
                            .frame(width: 145 * m.scale, height: 51 * m.scale)
                            .background(AppColors.grey800)
                            .clipShape(RoundedRectangle(cornerRadius: 45 * m.scale))
                            .shadow(radius: 2.5 * m.scale, y: 1 * m.scale)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .center)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppTypography.notoSans(12 * m.scale))
                            .foregroundStyle(AppColors.grey800.opacity(0.6))
                            .padding(.top, 10 * m.scale)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Button(action: onTapSignup) {
                        Text("회원가입")
                            .font(AppTypography.notoSans(14 * m.scale))
                            .foregroundStyle(AppColors.grey800)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 18 * m.scale)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 40 * m.scale)
                }
            .keyboardAvoiding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        }
    }
}

private struct UnderlineField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool
    let trailingIconSystemName: String?
    let onTapTrailing: (() -> Void)?
    let scale: CGFloat
    var onFocusChange: ((Bool) -> Void)? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppTypography.notoSans(16 * scale))
                .foregroundStyle(AppColors.grey800)

            Spacer(minLength: 8 * scale)

            HStack(spacing: 8 * scale) {
                Group {
                    if isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                    }
                }
                .font(AppTypography.notoSans(14 * scale))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.leading, (title == "학번" ? 3 : 4) * scale)
                .frame(height: 24 * scale)

                if let trailingIconSystemName, let onTapTrailing {
                    Button(action: onTapTrailing) {
                        Image(systemName: trailingIconSystemName)
                            .font(AppTypography.notoSans(16 * scale))
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(width: 44 * scale, height: 24 * scale)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 24 * scale)

            Spacer(minLength: 1 * scale)

            Rectangle()
                .fill(AppColors.grey800)
                .frame(width: (title == "학번" ? 287 : 286) * scale, height: 1 * scale, alignment: .leading)
        }
        .onChange(of: isFocused) { _, focused in
            onFocusChange?(focused)
        }
    }
}
