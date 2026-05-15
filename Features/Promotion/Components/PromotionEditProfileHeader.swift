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

    @ViewBuilder
    private var backgroundImageView: some View {
        PhotosPicker(selection: $backgroundPickerItem, matching: .images) {
            ZStack {
                if let data = vm.backgroundImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
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
        }
        .onChange(of: backgroundPickerItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    vm.backgroundImageData = data
                }
            }
        }
    }

    private var backgroundPlaceholder: some View {
        ZStack {
            Color(hex: 0x585858)
            Text("사진을 추가하세요")
                .font(AppTypography.notoSans(13, weight: .medium))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var profileImageView: some View {
        PhotosPicker(selection: $profilePickerItem, matching: .images) {
            ZStack {
                if let data = vm.profileImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
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
        }
        .onChange(of: profilePickerItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    vm.profileImageData = data
                }
            }
        }
    }

    private var profilePlaceholder: some View {
        ZStack {
            Color(hex: 0xCCCCCC)
            Text("사진을\n추가하세요")
                .font(AppTypography.notoSans(10, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
    }

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
