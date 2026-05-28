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

    @State private var backgroundOffset: CGSize = .zero
    @State private var backgroundDragOrigin: CGSize = .zero
    @State private var profileOffset: CGSize = .zero
    @State private var profileDragOrigin: CGSize = .zero

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
    }

    // MARK: - Background Image

    @ViewBuilder
    private var backgroundImageView: some View {
        let hasBackgroundImage = vm.backgroundImageData != nil || vm.backgroundImageURL != nil
        ZStack {
            backgroundImageContent

            if hasBackgroundImage {
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
        .frame(maxWidth: .infinity, maxHeight: backgroundImageHeight)
        .clipped()
        .onChange(of: backgroundPickerItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    vm.backgroundImageData = data
                    backgroundOffset = .zero
                    backgroundDragOrigin = .zero
                }
            }
        }
    }

    @ViewBuilder
    private var backgroundImageContent: some View {
        if let data = vm.backgroundImageData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .offset(backgroundOffset)
                .gesture(dragGesture(offset: $backgroundOffset, origin: $backgroundDragOrigin))
        } else if let url = vm.backgroundImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                        .scaledToFill()
                        .offset(backgroundOffset)
                        .gesture(dragGesture(offset: $backgroundOffset, origin: $backgroundDragOrigin))
                default:
                    backgroundPlaceholder
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

    // MARK: - Profile Image

    @ViewBuilder
    private var profileImageView: some View {
        let hasProfileImage = vm.profileImageData != nil || vm.profileImageURL != nil
        ZStack {
            profileImageContent

            if hasProfileImage {
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
        .onChange(of: profilePickerItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    vm.profileImageData = data
                    profileOffset = .zero
                    profileDragOrigin = .zero
                }
            }
        }
    }

    @ViewBuilder
    private var profileImageContent: some View {
        if let data = vm.profileImageData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .offset(profileOffset)
                .gesture(dragGesture(offset: $profileOffset, origin: $profileDragOrigin))
        } else if let url = vm.profileImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                        .scaledToFill()
                        .offset(profileOffset)
                        .gesture(dragGesture(offset: $profileOffset, origin: $profileDragOrigin))
                default:
                    profilePlaceholder
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

    // MARK: - Shared

    private var cameraChip: some View {
        Image(systemName: "camera.fill")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(.black.opacity(0.45))
            .clipShape(Circle())
    }

    private func dragGesture(
        offset: Binding<CGSize>,
        origin: Binding<CGSize>
    ) -> some Gesture {
        DragGesture()
            .onChanged { v in
                offset.wrappedValue = CGSize(
                    width:  origin.wrappedValue.width  + v.translation.width,
                    height: origin.wrappedValue.height + v.translation.height
                )
            }
            .onEnded { _ in
                origin.wrappedValue = offset.wrappedValue
            }
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
