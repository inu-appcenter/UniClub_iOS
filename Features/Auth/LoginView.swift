import SwiftUI

struct LoginView: View {
    let onLogin: (_ studentId: String, _ password: String) -> Void
    let onTapSignup: () -> Void

    @State private var studentId: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var errorMessage: String? = nil

    @FocusState private var focusedField: Field?

    private enum Field {
        case studentId
        case password
    }

    var body: some View {
        GeometryReader { geo in
            // ✅ Login_3.json은 360px 폭 기준 디자인이므로, 가로폭 기준 스케일로 맞춤
            let scale = geo.size.width / 360.0

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // 2) UniClub 로고 (Figma 추출 이미지: Assets -> logo_uniclub)
                    Image("logo_uniclub")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        // Figma JSON에서 "UniClub" 텍스트 박스 폭이 188로 잡혀있어 그 기준으로 맞춤
                        .frame(width: 188 * scale, alignment: .leading)
                        .padding(.top, 75 * scale)
                        .padding(.leading, 39 * scale)
                        .accessibilityLabel("UniClub 로고")
                    // 3) 로고 ↔ 입력영역 간격 (json 기준 y: 75 -> 439)
                    //   로고의 “프레임 높이”가 json에서 88로 잡혀있어서 그걸 기준으로 간격 계산
                    //   439 - (75 + 88) = 276
                    Spacer(minLength: 276 * scale)

                    // 입력 섹션 (x = 37, width = 294)
                    VStack(alignment: .leading, spacing: 0) {
                        UnderlineField(
                            title: "학번",
                            text: $studentId,
                            isSecure: false,
                            trailingIconSystemName: nil,
                            onTapTrailing: nil,
                            scale: scale
                        )
                        .focused($focusedField, equals: .studentId)
                        .padding(.bottom, 53 * scale) // 학번 입력영역 ~ 비밀번호 타이틀 간격 (json 근사)

                        UnderlineField(
                            title: "비밀번호",
                            text: $password,
                            isSecure: !showPassword,
                            trailingIconSystemName: showPassword ? "eye" : "eye.slash",
                            onTapTrailing: { showPassword.toggle() },
                            scale: scale
                        )
                        .focused($focusedField, equals: .password)
                    }
                    .frame(width: 294 * scale, alignment: .leading)
                    .padding(.leading, 37 * scale)

                    // 4) 비밀번호 입력영역 ~ 로그인 버튼 간격 (json 기준 약 52)
                    Spacer(minLength: 52 * scale)

                    // 4) 로그인 버튼 (json 기준: width 145, height 51, radius 45, black)
                    Button {
                        if studentId.isEmpty || password.isEmpty {
                            errorMessage = "학번과 비밀번호를 입력해주세요."
                            return
                        }
                        errorMessage = nil
                        onLogin(studentId, password)
                    } label: {
                        Text("로그인")
                            .font(.custom("NotoSansKR-Regular", size: 14 * scale))
                            .foregroundStyle(Color.white)
                            .frame(width: 145 * scale, height: 51 * scale)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 45 * scale))
                            .shadow(radius: 2.5 * scale, y: 1 * scale)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .center)

                    // 에러 메시지(디자인 단계에서 필요 없으면 제거 가능)
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.custom("NotoSansKR-Regular", size: 12 * scale))
                            .foregroundStyle(Color.black.opacity(0.6))
                            .padding(.top, 10 * scale)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // 5) 회원가입 텍스트 (json 기준 y 간격: 버튼 끝 -> 회원가입 18)
                    Button(action: onTapSignup) {
                        Text("회원가입")
                            .font(.custom("NotoSansKR-Regular", size: 14 * scale))
                            .foregroundStyle(Color.black)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 18 * scale)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 40 * scale)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .ignoresSafeArea(.container, edges: .top)
            // 6) 키보드 올라오면 입력창이 가려지지 않도록 전체를 밀어올림
            .keyboardAvoiding()
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                focusedField = nil
            }
        }
    }
}

/// Login_3.json의 underline 입력 스타일을 “수치 기반(scale)”으로 맞춘 버전
private struct UnderlineField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool
    let trailingIconSystemName: String?
    let onTapTrailing: (() -> Void)?
    let scale: CGFloat
    @Environment(\.appMetrics) private var m   // ✅ 추가

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // 타이틀 (json: 16)
            Text(title)
                .font(.custom("NotoSansKR-Regular", size: 16 * scale))
                .foregroundStyle(Color.black)

            
            // 타이틀 ↔ 입력값 간격 (JSON상 약 8px)
            Spacer(minLength: 8 * scale)

            HStack(spacing: m.space8) {

                Group {
                    if isSecure {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                            .keyboardType(title == "학번" ? .numberPad : .default)
                    }
                }
                // ✅ 입력 텍스트: JSON은 14pt → scale 반영
                .font(.custom("NotoSansKR-Regular", size: 14 * scale))
                .foregroundStyle(AppColors.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

                // ✅ 입력값은 타이틀보다 살짝 오른쪽(학번≈3px, 비번≈4px)
                .padding(.leading, (title == "학번" ? 3 : 4) * scale)

                // ✅ JSON에서 입력 영역 높이(텍스트 bbox)가 24로 잡힘
                .frame(height: 24 * scale)

                if let trailingIconSystemName, let onTapTrailing {
                    Button(action: onTapTrailing) {
                        Image(systemName: trailingIconSystemName)
                            .font(.system(size: 16 * scale))
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(width: 44 * scale, height: 24 * scale)  // 탭영역 확보
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 24 * scale)

            // ✅ 입력값 ↔ underline 간격: JSON은 거의 0~1px 수준
            Spacer(minLength: 1 * scale)

            Rectangle()
                .fill(Color.black)
                // ✅ underline 길이: 학번≈287, 비번≈286 (JSON 기준)
                .frame(width: (title == "학번" ? 287 : 286) * scale, height: 1 * scale, alignment: .leading)
        }
    }
}
