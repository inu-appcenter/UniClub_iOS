import SwiftUI

struct EditProfileImageBlock: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: EditProfileViewModel
    let onTapEdit: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            profileImageContainer

            Button(action: onTapEdit) {
                Image("icon_editview_mypage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .offset(x: 4, y: 4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var profileImageContainer: some View {
        if let data = vm.selectedImageData, let ui = UIImage(data: data) {
            RoundedRectangle(cornerRadius: 23)
                .fill(AppColors.background)
                .frame(width: 70, height: 69)
                .shadow(color: .black.opacity(0.25), radius: 3.6, x: 0, y: 4)
                .overlay {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 69)
                        .clipShape(RoundedRectangle(cornerRadius: 23))
                }
        } else if let url = vm.profileImageURL, !vm.isProfileImageRemoved {
            RoundedRectangle(cornerRadius: 23)
                .fill(AppColors.background)
                .frame(width: 70, height: 69)
                .shadow(color: .black.opacity(0.25), radius: 3.6, x: 0, y: 4)
                .overlay {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Image("image_default_mypage")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .id(url.absoluteString)
                    .frame(width: 70, height: 69)
                    .clipShape(RoundedRectangle(cornerRadius: 23))
                }
        } else {
            Image("image_default_mypage")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 69)
        }
    }
}
