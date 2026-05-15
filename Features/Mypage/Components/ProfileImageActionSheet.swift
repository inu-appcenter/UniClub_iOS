//
//  ProfileImageActionSheet.swift
//  UniClub
//
//  Created by 제욱 on 3/28/26.
//

import SwiftUI
import PhotosUI

struct ProfileImageActionSheet: View {
    @Environment(\.appMetrics) private var m

    @Binding var selection: PhotosPickerItem?
    let onDismiss: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.grey800.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
                    actionRow(
                        iconName: "icon_fix_pencil",
                        title: "프로필 사진 변경"
                    )
                }
                .buttonStyle(.plain)

                actionRowButton(
                    iconName: "icon_delete_trashcan",
                    title: "프로필 사진 삭제",
                    action: onDelete
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22 * m.scale)
            .background(Color(red: 0.168, green: 0.168, blue: 0.168))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 8 * m.scale)
            .padding(.bottom, 10 * m.scale)
        }
    }

    private func actionRowButton(
        iconName: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            actionRow(iconName: iconName, title: title)
        }
        .buttonStyle(.plain)
    }

    private func actionRow(
        iconName: String,
        title: String
    ) -> some View {
        HStack(spacing: 18 * m.scale) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text(title)
                .font(AppTypography.notoSans(13, weight: .medium))
                .foregroundStyle(AppColors.background)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24 * m.scale)
        .frame(height: 48 * m.scale)
        .contentShape(Rectangle())
    }
}
