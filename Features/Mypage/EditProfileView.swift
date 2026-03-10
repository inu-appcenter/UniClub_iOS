import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditProfileView: View {
    
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil   // 미리보기/업로드에 사용
    
    let onSaved: (() -> Void)?

    init(onSaved: (() -> Void)? = nil) {
        self.onSaved = onSaved
    }

    @Environment(\.appMetrics) private var m
    @Environment(\.dismiss) private var dismiss

    // JSON 1(사진 있음) / JSON 2(nopicture) 상태
    enum ProfileImageState {
        case hasImage
        case noImage
    }

    // MARK: - ViewModel
    @StateObject private var vm = EditProfileViewModel()

    // SignupStep1View에서 쓰던 학과 선택 시트 방식 그대로
    @State private var showMajorSheet: Bool = false

    private var imageState: ProfileImageState {
        vm.profileImageURL == nil ? .noImage : .hasImage
    }

    var body: some View {
        ScreenContainer(scroll: false) { _ in
            VStack(spacing: 0) {

                header
                    .padding(.top, m.space8)

                profileImageBlock
                    .padding(.top, m.space24)

                fieldsBlock
                    .padding(.top, m.space32)

                Spacer(minLength: 0)
            }
        }
        .overlay {
            // ✅ Collectmajor 1/2 Sheet (SignupStep1View와 동일)
            MajorPickerSheetView(
                isPresented: $showMajorSheet,
                onSelectMajor: { item in
                    vm.majorDisplay = item.display
                    vm.majorCode = item.code
                }
            )
        }
        .task {
            await vm.load()
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

    // MARK: - Header (뒤로 / 타이틀 / 저장)
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("프로필 수정")
                .font(AppTypography.bodyStrong())
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
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(vm.canSave ? AppColors.textPrimary : AppColors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(!vm.canSave || vm.isLoading)
        }
        .padding(.horizontal, m.space8)
        .frame(height: 44)
    }

    // MARK: - Profile Image (JSON 1 vs JSON 2)
    private var profileImageBlock: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                RoundedRectangle(cornerRadius: 23)
                    .fill(imageState == .hasImage ? AppColors.fieldFill : .white)
                    .frame(width: 70, height: 69)
                    .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 3)

                // ✅ 1순위: 새로 선택한 이미지 미리보기
                if let data = vm.selectedImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 69)
                        .clipShape(RoundedRectangle(cornerRadius: 23))

                // ✅ 2순위: 서버에 저장된 기존 이미지
                } else if let url = vm.profileImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            Image(systemName: "person.fill")
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .id(url.absoluteString) // ✅ URL 바뀌면 새로 로드 강제
                    .frame(width: 70, height: 69)
                    .clipShape(RoundedRectangle(cornerRadius: 23))

                // ✅ 3순위: 기본 아이콘
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                // ✅ 이미지 Data 로드
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    // contentType 추정 (가능하면 png/jpg 구분)
                    let ct = guessImageContentType(from: data) // 아래 helper
                    vm.setSelectedImage(data: data, contentType: ct)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // ✅ 간단 contentType 추정 (png 시그니처 검사)
    private func guessImageContentType(from data: Data) -> String {
        // PNG signature: 89 50 4E 47 0D 0A 1A 0A
        let pngSig: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        if data.count >= 8 {
            let head = [UInt8](data.prefix(8))
            if head == pngSig { return "image/png" }
        }
        return "image/jpeg"
    }

    // MARK: - Fields (닉네임 / 이름 / 학과)
    private var fieldsBlock: some View {
        VStack(spacing: 22) {
            labeledInputRow(title: "닉네임", text: $vm.nickname)
            labeledInputRow(title: "이름", text: $vm.name)
            majorRow
        }
        .padding(.horizontal, 24) // JSON 느낌(좌우 여백)
    }

    /// JSON처럼 "좌측 라벨 + 우측 입력 박스(회색)" 구조
    private func labeledInputRow(title: String, text: Binding<String>) -> some View {
        HStack(alignment: .center, spacing: m.space16) {
            Text(title)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 58, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(AppColors.fieldFill)
                    .frame(height: 31)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(AppColors.border, lineWidth: m.hairline)
                    )

                TextField("", text: text)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, m.space12)
                    .frame(height: 31)
            }
            .frame(maxWidth: .infinity)
        }
    }

    /// 학과 선택 (SignupStep1View와 동일 UX)
    private var majorRow: some View {
        HStack(alignment: .center, spacing: m.space16) {
            Text("학과")
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 58, alignment: .leading)

            Button {
                showMajorSheet = true
            } label: {
                HStack(spacing: m.space8) {
                    Text(!vm.majorDisplay.isEmpty ? vm.majorDisplay : "학과 선택")
                        .foregroundStyle(vm.majorDisplay.isEmpty ? AppColors.textSecondary : AppColors.textPrimary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal, m.space12)
                .frame(height: 31)
                .background(AppColors.fieldFill)
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(AppColors.border, lineWidth: m.hairline)
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
