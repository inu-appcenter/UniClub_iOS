//
//  EditProfileViewModel.swift
//  UniClub
//
//  Created by 제욱 on 2/11/26.
//

import Foundation
import Combine

@MainActor
final class EditProfileViewModel: ObservableObject {

    // MARK: - UI State
    @Published var nickname: String = ""
    @Published var name: String = ""
    @Published var majorDisplay: String = ""
    @Published var majorCode: String = ""

    @Published var profileImageURL: URL? = nil

    // ✅ 새로 선택한 이미지 (미리보기 + 업로드 대상)
    @Published var selectedImageData: Data? = nil
    @Published var selectedImageContentType: String? = nil   // "image/jpeg" 등

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Internal
    private var didInitialLoad: Bool = false
    private var original: UserMeResponse? = nil
    private var originalProfileLink: String? = nil   // ✅ 원본 링크 저장

    // ✅ 저장 가능 조건에 "이미지 변경"도 포함
    var canSave: Bool {
        guard let o = original else { return false }

        let nn = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let nm = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let mc = majorCode.trimmingCharacters(in: .whitespacesAndNewlines)

        if nn.isEmpty || nm.isEmpty || mc.isEmpty { return false }

        if nn != o.nickname { return true }
        if nm != o.name { return true }
        if mc != o.major { return true }

        // ✅ 사진 새로 선택했으면 저장 가능
        if selectedImageData != nil { return true }

        return false
    }

    func load(force: Bool = false) async {
        if didInitialLoad, !force { return }
        didInitialLoad = true

        isLoading = true
        errorMessage = nil

        do {
            let dto = try await UserService.me()
            original = dto

            nickname = dto.nickname
            name = dto.name
            majorCode = dto.major
            majorDisplay = MajorCatalog.all.first(where: { $0.code == dto.major })?.display ?? dto.major

            let link = (dto.profileImageLink ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            originalProfileLink = link.isEmpty ? nil : link

            // 화면 표시용 URL 구성 (서버가 절대/상대 중 뭘 주는지에 따라)
            if link.isEmpty {
                profileImageURL = nil
            } else if link.hasPrefix("http") {
                profileImageURL = URL(string: link)
            } else {
                // ✅ 상대경로라면 baseURL 붙여서 표시
                profileImageURL = URL(string: AppConfig.baseURL.absoluteString + "/" + link)
            }

            // ✅ 새로 선택한 이미지 상태는 load시 초기화(원하면 유지해도 됨)
            selectedImageData = nil
            selectedImageContentType = nil

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    /// ✅ View에서 이미지 선택 후 호출
    func setSelectedImage(data: Data, contentType: String) {
        selectedImageData = data
        selectedImageContentType = contentType
    }

    func save() async -> Bool {
        guard let o = original else { return false }

        let nn = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let nm = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let mc = majorCode.trimmingCharacters(in: .whitespacesAndNewlines)

        if nn.isEmpty || nm.isEmpty || mc.isEmpty {
            errorMessage = "닉네임/이름/학과를 모두 입력해주세요."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            // 1) ✅ 이미지가 선택됐으면: presigned → PUT → link 확보
            var newProfileLink: String? = nil
            if let data = selectedImageData {
                let contentType = selectedImageContentType ?? "image/jpeg"
                let ext = (contentType == "image/png") ? "png" : "jpg"
                let safeName = "profile_\(UUID().uuidString).\(ext)"

                let presigned = try await ProfileImageService.presigned(filename: safeName)

                guard let putURL = URL(string: presigned.presignedUrl) else {
                    throw APIError.badURL
                }

                try await HTTPClient.shared.putBinary(to: putURL, data: data, contentType: contentType)

                // ✅ presignedUrl에서 "uploads/....jpg" objectKey 추출해서 서버에 저장
                newProfileLink = extractS3ObjectKey(from: putURL)
            }

            // 2) PATCH: 변경된 값만 보내기
            let req = UpdateUserMeRequest(
                name: (nm != o.name) ? nm : nil,
                major: (mc != o.major) ? mc : nil,
                nickname: (nn != o.nickname) ? nn : nil,
                profileImageLink: newProfileLink // ✅ 이미지 변경 반영
            )

            // 아무 변경도 없으면 호출하지 않음
            if req.name == nil, req.major == nil, req.nickname == nil, req.profileImageLink == nil {
                isLoading = false
                return true
            }

            try await UserService.updateMe(req)

            // 3) 성공 후 재조회해서 UI 동기화
            await load(force: true)
            isLoading = false
            return true

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
            return false
        }
    }
}

private func extractS3ObjectKey(from url: URL) -> String {
    // 예: https://bucket.s3...amazonaws.com/uploads/2026-02-11/xxxx.jpg?...
    // → "uploads/2026-02-11/xxxx.jpg"
    let path = url.path  // "/uploads/2026-02-11/xxxx.jpg"
    if path.hasPrefix("/") {
        return String(path.dropFirst())
    }
    return path
}
