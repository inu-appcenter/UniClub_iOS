//import SwiftUI
//
//struct PromotionDetailView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Binding var isTabBarHidden: Bool
//
//    private let scrollSpace = "promotion.scroll"
//
//    // MARK: - Mock (나중에 VM/DTO로 교체)
//    private let clubName = "크레퍼스(CREPERS)"
//    private let tagline = "동아리에서 함께 연주하고 추억을 쌓아봐요!"
//    private let statusText = "모집중"
//
//    private let roomValue = "17호관 414호"
//    private let presidentValue = "이석준"
//    private let contactValue = "010.1234.5678"
//
//    private let recruitValue = "7월 16일 ~ 24일  오후 6시"
//    private let noticeValue = "25일 동아리실 출입금지"
//
//    private let descriptionText =
//    "이 글은 동아리 소개 예시글입니다. 저희 동아리는 전공과 학년을 넘어 다양한 사람들이 모여 공통의 관심사를 나누고, 함께 경험을 쌓아가는 공간입니다. 활동 하나하나에 진심을 담고, 소소한 일상도 특별하게 만드는 우리! 처음이라도 괜찮아요. 언제든 환영합니다. 당신의 자리를 만들어드릴게요."
//
//    var body: some View {
//        ScreenContainer(scroll: false) { _ in
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    headerHero
//
//                    content
//                        .padding(.top, 18)
//
//                    bottomButtons
//                        .padding(.top, 24)
//                        .padding(.horizontal, 20)
//                }
//                // ✅ 탭바 가려도 OK: 하단 여백 없음
//                .observeScrollDirection(
//                    in: scrollSpace,
//                    threshold: 6,
//                    onScrollDown: { isTabBarHidden = true },
//                    onScrollUp: { isTabBarHidden = false }
//                )
//            }
//            .coordinateSpace(name: scrollSpace)
//        }
//        .onAppear { isTabBarHidden = false } // 화면 진입 시 기본 노출
//    }
//
//    // MARK: - Header (상단 이미지 + 뒤로/공유)
//    private var headerHero: some View {
//        ZStack(alignment: .top) {
//            Rectangle()
//                .fill(Color.black.opacity(0.12))
//                .frame(height: 209)
//                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
//                .overlay(alignment: .top) {
//                    Rectangle()
//                        .fill(AppColors.brand.opacity(0.5))
//                        .frame(height: 63)
//                        .blur(radius: 16)
//                }
//
//            HStack {
//                iconButton(system: "chevron.left") { dismiss() }
//                Spacer()
//                iconButton(system: "square.and.arrow.up") {
//                    // NOTE(기능 연동 전):
//                    // - 공유 기능(ShareLink / UIActivityViewController) 연동 예정
//                    // - API 필요 여부 확정 후 구현한다.
//                }
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 12)
//        }
//    }
//
//    private func iconButton(system: String, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Image(systemName: system)
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundStyle(.white)
//                .frame(width: 30, height: 30)
//                .background(AppColors.brand)
//                .clipShape(Circle())
//        }
//        .buttonStyle(.plain)
//    }
//
//    // MARK: - Main Content
//    private var content: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            topInfoRow
//
//            Divider()
//                .overlay(AppColors.border)
//                .padding(.top, 16)
//
//            infoPairs
//                .padding(.top, 18)
//
//            Text(descriptionText)
//                .font(.custom("NotoSansKR-Regular", size: 13))
//                .foregroundStyle(AppColors.textPrimary)
//                .lineSpacing(5)
//                .padding(.top, 22)
//
//            mediaStrip
//                .padding(.top, 22)
//        }
//        .padding(.horizontal, 20)
//    }
//
//    private var topInfoRow: some View {
//        HStack(alignment: .top, spacing: 14) {
//            RoundedRectangle(cornerRadius: 40, style: .continuous)
//                .fill(Color.black.opacity(0.20))
//                .frame(width: 113, height: 113)
//                .overlay(
//                    Image(systemName: "music.note")
//                        .font(.system(size: 28, weight: .bold))
//                        .foregroundStyle(.white.opacity(0.9))
//                )
//
//            VStack(alignment: .leading, spacing: 10) {
//                HStack(spacing: 10) {
//                    Text(clubName)
//                        .font(.custom("NotoSansKR-Medium", size: 13))
//                        .foregroundStyle(.white)
//                        .padding(.horizontal, 14)
//                        .frame(height: 30)
//                        .background(AppColors.brand)
//                        .clipShape(Capsule())
//
//                    Text(statusText)
//                        .font(.custom("NotoSansKR-Regular", size: 10))
//                        .foregroundStyle(.white)
//                        .padding(.horizontal, 10)
//                        .frame(height: 18)
//                        .background(Color.black.opacity(0.78))
//                        .clipShape(Capsule())
//                }
//
//                Text(tagline)
//                    .font(.custom("NotoSansKR-Bold", size: 10))
//                    .foregroundStyle(AppColors.brand)
//
//                HStack(spacing: 18) {
//                    miniInfo(title: "동아리방", value: roomValue)
//                    miniInfo(title: "회장", value: presidentValue)
//                    miniInfo(title: "연락처", value: contactValue)
//                }
//            }
//
//            Spacer(minLength: 0)
//        }
//        .padding(.top, 14)
//    }
//
//    private func miniInfo(title: String, value: String) -> some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(title)
//                .font(.custom("NotoSansKR-Bold", size: 10))
//                .foregroundStyle(AppColors.textPrimary)
//
//            Text(value)
//                .font(.custom("NotoSansKR-Regular", size: 9))
//                .foregroundStyle(AppColors.textPrimary)
//        }
//    }
//
//    private var infoPairs: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack(spacing: 18) {
//                Text("모집기간")
//                    .font(.custom("NotoSansKR-Bold", size: 10))
//                    .frame(width: 60, alignment: .leading)
//
//                Text(recruitValue)
//                    .font(.custom("NotoSansKR-Medium", size: 10))
//
//                Spacer()
//            }
//
//            HStack(spacing: 18) {
//                Text("공지")
//                    .font(.custom("NotoSansKR-Bold", size: 10))
//                    .frame(width: 60, alignment: .leading)
//
//                Text(noticeValue)
//                    .font(.custom("NotoSansKR-Medium", size: 10))
//
//                Spacer()
//            }
//        }
//        .foregroundStyle(AppColors.textPrimary)
//    }
//
//    // MARK: - Media Strip
//    private var mediaStrip: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                mediaCard(width: 139, height: 183, corner: 25)
//                mediaCard(width: 139, height: 183, corner: 25)
//                mediaCard(width: 63, height: 183, corner: 25, isTrailingCrop: true)
//            }
//            .padding(.vertical, 4)
//        }
//    }
//
//    private func mediaCard(width: CGFloat, height: CGFloat, corner: CGFloat, isTrailingCrop: Bool = false) -> some View {
//        let shape: AnyShape = {
//            if isTrailingCrop {
//                return AnyShape(
//                    UnevenRoundedRectangle(
//                        topLeadingRadius: corner,
//                        bottomLeadingRadius: corner,
//                        bottomTrailingRadius: 0,
//                        topTrailingRadius: 0
//                    )
//                )
//            }
//            return AnyShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
//        }()
//
//        return Rectangle()
//            .fill(Color.black.opacity(0.12))
//            .frame(width: width, height: height)
//            .clipShape(shape)
//            .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
//    }
//
//    // MARK: - Bottom Buttons (페이지의 일부)
//    private var bottomButtons: some View {
//        HStack(spacing: 14) {
//            Button {
//                // TODO: 질문하기
//            } label: {
//                Text("질문하기")
//                    .font(.custom("NotoSansKR-Regular", size: 15))
//                    .foregroundStyle(.white)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 54)
//                    .background(Color(red: 0.168, green: 0.168, blue: 0.168))
//                    .clipShape(Capsule())
//            }
//            .buttonStyle(.plain)
//
//            Button {
//                // TODO: 지원하기
//            } label: {
//                Text("지원하기")
//                    .font(.custom("NotoSansKR-Regular", size: 15))
//                    .foregroundStyle(.white)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 54)
//                    .background(AppColors.brand)
//                    .clipShape(Capsule())
//            }
//            .buttonStyle(.plain)
//        }
//    }
//}
//
//#Preview("PromotionDetailView") {
//    NavigationStack {
//        PromotionDetailView(isTabBarHidden: .constant(false))
//    }
//}
//
//// MARK: - Shape helper
//private struct AnyShape: Shape {
//    private let _path: (CGRect) -> Path
//    init<S: Shape>(_ shape: S) { _path = { rect in shape.path(in: rect) } }
//    func path(in rect: CGRect) -> Path { _path(rect) }
//}
