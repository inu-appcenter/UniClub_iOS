import Foundation

enum PromotionService {

    // MARK: - DTOs

    struct ClubPromotionDTO: Decodable {
        let role: String
        let name: String
        let status: String
        let startTime: String?
        let endTime: String?
        let simpleDescription: String?
        let description: String?
        let favorite: Bool
        let notice: String?
        let location: String?
        let presidentName: String?
        let presidentPhone: String?
        let youtubeLink: String?
        let instagramLink: String?
        let applicationFormLink: String?
        let mediaList: [MediaDTO]
    }

    struct MediaDTO: Decodable, Identifiable {
        var id: String { mediaLink }
        let mediaLink: String
        let mediaType: MediaType
        let main: Bool
        let updatedAt: String?

        var url: URL? { URL(string: mediaLink) }

        enum MediaType: String, Decodable {
            case mainPage       = "MAIN_PAGE"
            case clubPromotion  = "CLUB_PROMOTION"
            case clubProfile    = "CLUB_PROFILE"
            case clubBackground = "CLUB_BACKGROUND"
            case userProfile    = "USER_PROFILE"
            case unknown

            init(from decoder: Decoder) throws {
                let raw = try decoder.singleValueContainer().decode(String.self)
                self = MediaType(rawValue: raw) ?? .unknown
            }
        }
    }

    struct ToggleFavoriteDTO: Decodable {
        let message: String
    }

    struct ClubPromotionRequestDTO: Encodable {
        let name: String?
        let status: String?
        let startTime: String?
        let endTime: String?
        let simpleDescription: String?
        let description: String?
        let notice: String?
        let location: String?
        let presidentName: String?
        let presidentPhone: String?
        let youtubeLink: String?
        let instagramLink: String?
        let applicationFormLink: String?
    }

    struct S3PresignedResponseDTO: Decodable {
        let filename: String
        let presignedUrl: String
    }

    struct MediaUploadItemDTO: Encodable {
        let mediaLink: String
        let mediaType: String
        let main: Bool
    }

    // MARK: - API

    static func fetchPromotion(clubId: Int) async throws -> ClubPromotionDTO {
        try await HTTPClient.shared.get(
            AppConfig.API.Clubs.detail(clubId),
            as: ClubPromotionDTO.self
        )
    }

    static func toggleFavorite(clubId: Int) async throws -> ToggleFavoriteDTO {
        struct EmptyBody: Encodable {}
        return try await HTTPClient.shared.postJSON(
            AppConfig.API.Clubs.favorite(clubId),
            body: EmptyBody(),
            as: ToggleFavoriteDTO.self
        )
    }

    static func savePromotion(clubId: Int, body: ClubPromotionRequestDTO) async throws {
        _ = try await HTTPClient.shared.putJSONRaw(
            AppConfig.API.Clubs.detail(clubId),
            body: body
        )
    }

    static func getPresignedUrl(clubId: Int) async throws -> S3PresignedResponseDTO {
        struct EmptyBody: Encodable {}
        return try await HTTPClient.shared.postJSON(
            AppConfig.API.Clubs.s3Presigned(clubId),
            body: EmptyBody(),
            as: S3PresignedResponseDTO.self
        )
    }

    static func uploadMedia(clubId: Int, items: [MediaUploadItemDTO]) async throws {
        _ = try await HTTPClient.shared.postJSONRaw(
            AppConfig.API.Clubs.upload(clubId),
            body: items
        )
    }

    static func uploadToS3(presignedUrl: String, data: Data, mimeType: String = "image/jpeg") async throws {
        guard let url = URL(string: presignedUrl) else { throw APIError.badURL }
        try await HTTPClient.shared.putBinary(to: url, data: data, contentType: mimeType)
    }

    private struct EmptyResponse: Decodable {}
}
