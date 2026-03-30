//
//  EditProfileViewModel.swift
//  UniClub
//
//  Created by 제욱 on 2/11/26.
//

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

    @Published var nickname: String = ""
    @Published var name: String = ""
    @Published var majorDisplay: String = ""
    @Published var majorCode: String = ""

    @Published var profileImageURL: URL? = nil
    @Published var selectedImageData: Data? = nil
    @Published var selectedImageContentType: String? = nil
    @Published var isProfileImageRemoved: Bool = false

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var didInitialLoad: Bool = false
    private var original: UserMeResponse? = nil
    private var originalProfileLink: String? = nil

    var canSave: Bool {
        guard let o = original else { return false }

        let nn = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let nm = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let mc = majorCode.trimmingCharacters(in: .whitespacesAndNewlines)

        if nn.isEmpty || nm.isEmpty || mc.isEmpty { return false }

        if nn != o.nickname { return true }
        if nm != o.name { return true }
        if mc != o.major { return true }
        if selectedImageData != nil { return true }
        if isProfileImageRemoved, originalProfileLink != nil { return true }

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

            if link.isEmpty {
                profileImageURL = nil
            } else if link.hasPrefix("http") {
                profileImageURL = URL(string: link)
            } else {
                profileImageURL = URL(string: AppConfig.baseURL.absoluteString + "/" + link)
            }

            selectedImageData = nil
            selectedImageContentType = nil
            isProfileImageRemoved = false

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    func setSelectedImage(data: Data, contentType: String) {
        selectedImageData = data
        selectedImageContentType = contentType
        isProfileImageRemoved = false
    }

    func removeSelectedProfileImage() {
        selectedImageData = nil
        selectedImageContentType = nil
        isProfileImageRemoved = true
        profileImageURL = nil
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
                newProfileLink = extractS3ObjectKey(from: putURL)
            } else if isProfileImageRemoved {
                newProfileLink = ""
            }

            let req = UpdateUserMeRequest(
                name: (nm != o.name) ? nm : nil,
                major: (mc != o.major) ? mc : nil,
                nickname: (nn != o.nickname) ? nn : nil,
                profileImageLink: newProfileLink
            )

            if req.name == nil, req.major == nil, req.nickname == nil, req.profileImageLink == nil {
                isLoading = false
                return true
            }

            try await UserService.updateMe(req)

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
    let path = url.path
    if path.hasPrefix("/") {
        return String(path.dropFirst())
    }
    return path
}
