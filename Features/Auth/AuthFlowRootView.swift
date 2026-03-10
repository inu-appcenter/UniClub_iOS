import SwiftUI

@available(*, deprecated, message: "AuthFlowRootView는 더 이상 사용하지 않습니다. AuthRootView를 사용하세요.")
struct AuthFlowRootView: View {
    var body: some View {
        AuthRootView()
    }
}

#Preview("AuthFlowRootView") {
    AuthFlowRootView()
}
