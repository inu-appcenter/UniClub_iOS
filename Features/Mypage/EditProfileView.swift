import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditProfileView: View {
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showMajorSheet: Bool = false
    @State private var showProfileImageActionSheet: Bool = false

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
                AppPageHeader(onBack: { dismiss() }) {
                    Text("프로필 수정")
                        .font(AppTypography.notoSans(15, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                } trailing: {
                    Button {
                        Task {
                            let ok = await vm.save()
                            if ok { onSaved?(); dismiss() }
                        }
                    } label: {
                        Text("저장")
                            .font(AppTypography.notoSans(12, weight: .medium))
                            .foregroundStyle(vm.canSave ? AppColors.textPrimary : AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!vm.canSave || vm.isLoading)
                }

                EditProfileImageBlock(vm: vm, onTapEdit: { showProfileImageActionSheet = true })
                    .padding(.top, m.space24)

                EditProfileFieldsBlock(
                    vm: vm,
                    onTapMajor: { showMajorSheet = true },
                    isMajorSheetVisible: showMajorSheet
                )
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
                    AppColors.grey800.opacity(0.08).ignoresSafeArea()
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
                .padding(m.space16)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: m.radius12))
                .padding(.horizontal, m.space16)
            }
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
}

#Preview {
    NavigationStack {
        EditProfileView()
    }
}
