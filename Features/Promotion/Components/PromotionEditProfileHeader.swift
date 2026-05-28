import SwiftUI
import PhotosUI

struct PromotionEditProfileHeader: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionEditViewModel
    let onTapApplication: () -> Void
    let onTapYoutube: () -> Void
    let onTapInstagram: () -> Void

    @State private var backgroundPickerItem: PhotosPickerItem?
    @State private var profilePickerItem: PhotosPickerItem?

    // UIImage 캐시 — Data를 매 렌더링마다 디코딩하지 않도록
    @State private var bgUIImage: UIImage?
    @State private var pfUIImage: UIImage?

    @State private var bgOffset: CGSize = .zero
    @State private var bgOffsetOrigin: CGSize = .zero
    @State private var bgScale: CGFloat = 1.0
    @State private var bgScaleOrigin: CGFloat = 1.0

    @State private var pfOffset: CGSize = .zero
    @State private var pfOffsetOrigin: CGSize = .zero
    @State private var pfScale: CGFloat = 1.0
    @State private var pfScaleOrigin: CGFloat = 1.0

    private var topBackgroundHeight: CGFloat { m.scale * 276 }
    private var backgroundImageHeight: CGFloat { m.scale * 209 }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundImageView
                .frame(maxWidth: .infinity, maxHeight: backgroundImageHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()

            HStack(alignment: .bottom, spacing: 0) {
                profileImageView
                    .frame(width: m.scale * 113, height: m.scale * 113)
                    .clipShape(RoundedRectangle(cornerRadius: m.radius24, style: .continuous))
                    .padding(.leading, m.space24)
                    .padding(.bottom, m.scale * 15)

                Spacer()

                socialEditRow
                    .padding(.trailing, m.scale * 21)
                    .padding(.bottom, m.space20)
            }
        }
        .frame(height: topBackgroundHeight)
        .clipped()
        .onAppear {
            if bgUIImage == nil, let d = vm.backgroundImageData { bgUIImage = UIImage(data: d) }
            if pfUIImage == nil, let d = vm.profileImageData    { pfUIImage = UIImage(data: d) }
        }
    }

    // MARK: - Background Image View

    @ViewBuilder
    private var backgroundImageView: some View {
        let hasImage = bgUIImage != nil || vm.backgroundImageURL != nil
        GeometryReader { geo in
            ZStack {
                backgroundContent(containerSize: geo.size)

                if hasImage {
                    Button { deleteBackground() } label: { trashChip }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(.trailing, m.space12)
                        .padding(.top, m.space8)

                    PhotosPicker(selection: $backgroundPickerItem, matching: .images) {
                        cameraChip
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, m.space12)
                    .padding(.bottom, m.space8)
                } else {
                    PhotosPicker(selection: $backgroundPickerItem, matching: .images) {
                        Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .onChange(of: backgroundPickerItem) { item in
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                vm.backgroundImageData = data
                bgUIImage = UIImage(data: data)
                resetBg()
            }
        }
    }

    @ViewBuilder
    private func backgroundContent(containerSize: CGSize) -> some View {
        if let ui = bgUIImage {
            // Color.clear.frame 이 레이아웃 앵커 역할 — offset이 부모 크기에 영향 안 줌
            Color.clear
                .frame(width: containerSize.width, height: containerSize.height)
                .overlay(
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(bgScale)
                        .offset(bgOffset)
                        .allowsHitTesting(false)
                )
                .clipped()
                .contentShape(Rectangle())
                .gesture(gesture(
                    imageSize: ui.size, containerSize: containerSize,
                    scale: $bgScale, scaleOrigin: $bgScaleOrigin,
                    offset: $bgOffset, offsetOrigin: $bgOffsetOrigin
                ))
        } else if let url = vm.backgroundImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: backgroundPlaceholder
                }
            }
        } else {
            backgroundPlaceholder
        }
    }

    private var backgroundPlaceholder: some View {
        ZStack {
            Color(hex: 0x585858)
            VStack(spacing: m.space6) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.6))
                Text("사진을 추가하세요")
                    .font(AppTypography.notoSans(13, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Profile Image View

    @ViewBuilder
    private var profileImageView: some View {
        let hasImage = pfUIImage != nil || vm.profileImageURL != nil
        GeometryReader { geo in
            ZStack {
                profileContent(containerSize: geo.size)

                if hasImage {
                    Button { deleteProfile() } label: { trashChip }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(m.space4)

                    PhotosPicker(selection: $profilePickerItem, matching: .images) {
                        cameraChip
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(m.space4)
                } else {
                    PhotosPicker(selection: $profilePickerItem, matching: .images) {
                        Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .onChange(of: profilePickerItem) { item in
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                vm.profileImageData = data
                pfUIImage = UIImage(data: data)
                resetPf()
            }
        }
    }

    @ViewBuilder
    private func profileContent(containerSize: CGSize) -> some View {
        if let ui = pfUIImage {
            Color.clear
                .frame(width: containerSize.width, height: containerSize.height)
                .overlay(
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(pfScale)
                        .offset(pfOffset)
                        .allowsHitTesting(false)
                )
                .clipped()
                .contentShape(Rectangle())
                .gesture(gesture(
                    imageSize: ui.size, containerSize: containerSize,
                    scale: $pfScale, scaleOrigin: $pfScaleOrigin,
                    offset: $pfOffset, offsetOrigin: $pfOffsetOrigin
                ))
        } else if let url = vm.profileImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: profilePlaceholder
                }
            }
        } else {
            profilePlaceholder
        }
    }

    private var profilePlaceholder: some View {
        ZStack {
            Color(hex: 0xCCCCCC)
            VStack(spacing: m.space4) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.6))
                Text("사진을\n추가하세요")
                    .font(AppTypography.notoSans(10, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Gesture (drag + pinch simultaneously)

    private func gesture(
        imageSize: CGSize,
        containerSize: CGSize,
        scale: Binding<CGFloat>,
        scaleOrigin: Binding<CGFloat>,
        offset: Binding<CGSize>,
        offsetOrigin: Binding<CGSize>
    ) -> some Gesture {
        let drag = DragGesture(minimumDistance: 1)
            .onChanged { v in
                let raw = CGSize(
                    width:  offsetOrigin.wrappedValue.width  + v.translation.width,
                    height: offsetOrigin.wrappedValue.height + v.translation.height
                )
                offset.wrappedValue = clamped(raw,
                    imageSize: imageSize, containerSize: containerSize, userScale: scale.wrappedValue)
            }
            .onEnded { _ in
                offsetOrigin.wrappedValue = offset.wrappedValue
            }

        let pinch = MagnificationGesture()
            .onChanged { value in
                let s = max(1.0, min(4.0, scaleOrigin.wrappedValue * value))
                scale.wrappedValue = s
                // 스케일 변경 시 기존 offset이 범위를 벗어날 수 있으므로 재클램핑
                offset.wrappedValue = clamped(offset.wrappedValue,
                    imageSize: imageSize, containerSize: containerSize, userScale: s)
            }
            .onEnded { _ in
                scaleOrigin.wrappedValue = scale.wrappedValue
                offsetOrigin.wrappedValue = offset.wrappedValue
            }

        return drag.simultaneously(with: pinch)
    }

    // MARK: - Clamping

    /// scaledToFill + userScale 기준으로 이미지가 컨테이너를 얼마나 넘치는지 계산 →
    /// 그 값이 곧 offset의 최대 허용 범위 (넘으면 빈 배경이 보임)
    private func clamped(
        _ offset: CGSize,
        imageSize: CGSize,
        containerSize: CGSize,
        userScale: CGFloat
    ) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0,
              containerSize.width > 0, containerSize.height > 0 else { return .zero }
        let fill = max(containerSize.width / imageSize.width,
                       containerSize.height / imageSize.height)
        let maxX = max(0, (imageSize.width  * fill * userScale - containerSize.width)  / 2)
        let maxY = max(0, (imageSize.height * fill * userScale - containerSize.height) / 2)
        return CGSize(
            width:  max(-maxX, min(maxX, offset.width)),
            height: max(-maxY, min(maxY, offset.height))
        )
    }

    // MARK: - Delete

    private func deleteBackground() {
        vm.backgroundImageData = nil
        vm.backgroundImageURL  = nil
        bgUIImage = nil
        resetBg()
    }

    private func deleteProfile() {
        vm.profileImageData = nil
        vm.profileImageURL  = nil
        pfUIImage = nil
        resetPf()
    }

    private func resetBg() {
        bgOffset = .zero; bgOffsetOrigin = .zero
        bgScale  = 1.0;  bgScaleOrigin  = 1.0
    }

    private func resetPf() {
        pfOffset = .zero; pfOffsetOrigin = .zero
        pfScale  = 1.0;  pfScaleOrigin  = 1.0
    }

    // MARK: - Shared Chips

    private var cameraChip: some View {
        Image(systemName: "camera.fill")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(.black.opacity(0.45))
            .clipShape(Circle())
    }

    private var trashChip: some View {
        Image(systemName: "trash.fill")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(.black.opacity(0.45))
            .clipShape(Circle())
    }

    // MARK: - Social Edit Row

    private var socialEditRow: some View {
        HStack(spacing: m.space8) {
            Button(action: onTapApplication) {
                Text("지원 링크")
                    .font(AppTypography.notoSans(10, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, m.space10)
                    .frame(height: m.scale * 26)
                    .background(AppColors.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button(action: onTapYoutube) {
                Image("icon_link_youtube")
                    .resizable().scaledToFit()
                    .frame(width: m.scale * 30, height: m.scale * 30)
            }
            .buttonStyle(.plain)
            .padding(m.space2)

            Button(action: onTapInstagram) {
                Image("icon_link_instagram")
                    .resizable().scaledToFit()
                    .frame(width: m.scale * 30, height: m.scale * 30)
            }
            .buttonStyle(.plain)
            .padding(m.space2)
        }
    }
}
