import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditProfileView: View {
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showMajorSheet: Bool = false
    @State private var showProfileImageActionSheet: Bool = false

    @FocusState private var focusedField: Field?

    enum Field {
        case name
        case nickname
    }

    let onSaved: (() -> Void)?

    init(onSaved: (() -> Void)? = nil) {
        self.onSaved = onSaved
    }

    @Environment(\.appMetrics) private var m
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = EditProfileViewModel()

    var body: some View {
        ScreenContainer(
            scroll: false,
            topPadding: .none,
            bottomPadding: .default
        ) { _ in
            VStack(spacing: 0) {
                header
                    .padding(.top, m.space8)

                profileImageBlock
                    .padding(.top, m.space24)

                fieldsBlock
                    .padding(.top, 54 * m.scale)

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            MajorPickerSheetView(
                isPresented: $showMajorSheet,
                onSelectMajor: { item in
                    vm.majorDisplay = item.display
                    vm.majorCode = item.code
                }
            )
        }
        .overlay {
            if showProfileImageActionSheet {
                ProfileImageActionSheet(
                    selection: $selectedPhotoItem,
                    onDismiss: {
                        showProfileImageActionSheet = false
                    },
                    onDelete: {
                        vm.removeSelectedProfileImage()
                        showProfileImageActionSheet = false
                    }
                )
            }
        }
        .task {
            await vm.load()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    let contentType = guessImageContentType(from: data)
                    vm.setSelectedImage(data: data, contentType: contentType)
                }
                showProfileImageActionSheet = false
            }
        }
        .overlay {
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.08).ignoresSafeArea()
                    ProgressView()
                }
            }

            if let msg = vm.errorMessage, !msg.isEmpty {
                VStack(spacing: 10) {
                    Text(msg)
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Button("다시 시도") {
                        Task { await vm.load(force: true) }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("프로필 수정")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Button {
                Task {
                    let ok = await vm.save()
                    if ok {
                        onSaved?()
                        dismiss()
                    }
                }
            } label: {
                Text("저장")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(vm.canSave ? AppColors.textPrimary : AppColors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(!vm.canSave || vm.isLoading)
        }
        .padding(.horizontal, m.space8)
        .frame(height: 44)
    }

    private var profileImageBlock: some View {
        ZStack(alignment: .bottomTrailing) {
            profileImageContainer

            Button {
                showProfileImageActionSheet = true
            } label: {
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
                .fill(Color.white)
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
                .fill(Color.white)
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

    private func guessImageContentType(from data: Data) -> String {
        let pngSig: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        if data.count >= 8 {
            let head = [UInt8](data.prefix(8))
            if head == pngSig { return "image/png" }
        }
        return "image/jpeg"
    }

    private var fieldsBlock: some View {
        VStack(spacing: 15 * m.scale) {
            majorRow
            labeledInputRow(title: "이름", text: $vm.name, field: .name)
            labeledInputRow(title: "닉네임", text: $vm.nickname, field: .nickname)
        }
        .padding(.horizontal, 30 * m.scale)
    }

    private func labeledInputRow(
        title: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        HStack(alignment: .center, spacing: 14 * m.scale) {
            Text(title)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 50 * m.scale, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color(red: 0.9567, green: 0.9567, blue: 0.9567))
                    .frame(height: 31)

                TextField("", text: text)
                    .focused($focusedField, equals: field)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 14 * m.scale)
                    .frame(height: 31)
            }
            .frame(width: 196 * m.scale, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .stroke(
                        focusedField == field ? Color.orange : .clear,
                        lineWidth: focusedField == field ? 0.5 : 0
                    )
            )
        }
    }

    private var majorRow: some View {
        HStack(alignment: .center, spacing: 14 * m.scale) {
            Text("학과")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 50 * m.scale, alignment: .leading)

            Button {
                showMajorSheet = true
            } label: {
                HStack(spacing: m.space8) {
                    Text(vm.majorDisplay.isEmpty ? "학과 선택" : vm.majorDisplay)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(vm.majorDisplay.isEmpty ? AppColors.textSecondary : AppColors.textPrimary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(showMajorSheet ? Color.orange : Color(red: 0.462, green: 0.462, blue: 0.462))
                }
                .padding(.horizontal, 14 * m.scale)
                .frame(width: 196 * m.scale, height: 31)
                .background(Color(red: 0.9567, green: 0.9567, blue: 0.9567))
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(
                            showMajorSheet ? Color.orange : .clear,
                            lineWidth: showMajorSheet ? 0.5 : 0
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
    }
}
