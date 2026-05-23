import Foundation
import Combine

@MainActor
final class PromotionEditViewModel: ObservableObject {

    // MARK: - 편집 필드
    @Published var name: String = ""
    @Published var status: String = "ACTIVE"
    @Published var startDate: Date? = nil    // DatePicker 바인딩, save 시 ISO로 변환
    @Published var endDate: Date? = nil
    @Published var simpleDescription: String = ""
    @Published var description: String = ""
    @Published var notice: String = ""
    @Published var location: String = ""
    @Published var presidentName: String = ""
    @Published var presidentPhone: String = ""
    @Published var youtubeLink: String = ""
    @Published var instagramLink: String = ""
    @Published var applicationFormLink: String = ""

    // MARK: - 이미지
    @Published var backgroundImageURL: URL?
    @Published var backgroundImageData: Data?
    @Published var profileImageURL: URL?
    @Published var profileImageData: Data?
    @Published var promotionImages: [PromotionService.MediaDTO] = []

    // MARK: - UI 상태
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var saveSuccess = false

    var statusText: String {
        switch status {
        case "ACTIVE":    return "모집중"
        case "CLOSED":    return "모집마감"
        case "SCHEDULED": return "모집예정"
        default:          return status
        }
    }

    private let clubId: Int

    init(clubId: Int) {
        self.clubId = clubId
    }

    // MARK: - 데이터 로드

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let dto = try await PromotionService.fetchPromotion(clubId: clubId)
            name                = dto.name
            status              = dto.status
            startDate           = Self.parseISO(dto.startTime)
            endDate             = Self.parseISO(dto.endTime)
            simpleDescription   = dto.simpleDescription ?? ""
            description         = dto.description ?? ""
            notice              = dto.notice ?? ""
            location            = dto.location ?? ""
            presidentName       = dto.presidentName ?? ""
            presidentPhone      = dto.presidentPhone ?? ""
            youtubeLink         = dto.youtubeLink ?? ""
            instagramLink       = dto.instagramLink ?? ""
            applicationFormLink = dto.applicationFormLink ?? ""

            backgroundImageURL  = dto.mediaList.first(where: { $0.mediaType == .clubBackground })?.url
            profileImageURL     = dto.mediaList.first(where: { $0.mediaType == .clubProfile })?.url
            promotionImages     = dto.mediaList.filter { $0.mediaType == .clubPromotion }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - 저장

    func save() async {
        isSaving = true
        errorMessage = nil
        do {
            let body = PromotionService.ClubPromotionRequestDTO(
                name:               nilIfEmpty(name),
                status:             nilIfEmpty(status),
                startTime:          Self.formatISO(startDate),
                endTime:            Self.formatISO(endDate),
                simpleDescription:  nilIfEmpty(simpleDescription),
                description:        nilIfEmpty(description),
                notice:             nilIfEmpty(notice),
                location:           nilIfEmpty(location),
                presidentName:      nilIfEmpty(presidentName),
                presidentPhone:     nilIfEmpty(presidentPhone),
                youtubeLink:        nilIfEmpty(youtubeLink),
                instagramLink:      nilIfEmpty(instagramLink),
                applicationFormLink: nilIfEmpty(applicationFormLink)
            )
            try await PromotionService.savePromotion(clubId: clubId, body: body)

            if let data = backgroundImageData {
                try await uploadImage(data: data, mediaType: "CLUB_BACKGROUND", main: true)
            }
            if let data = profileImageData {
                try await uploadImage(data: data, mediaType: "CLUB_PROFILE", main: true)
            }

            saveSuccess = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isSaving = false
    }

    // MARK: - 상태 순환

    func cycleStatus() {
        switch status {
        case "SCHEDULED": status = "ACTIVE"
        case "ACTIVE":    status = "CLOSED"
        default:          status = "SCHEDULED"
        }
    }

    // MARK: - Private

    private func uploadImage(data: Data, mediaType: String, main: Bool) async throws {
        let presigned = try await PromotionService.getPresignedUrl(clubId: clubId)
        try await PromotionService.uploadToS3(presignedUrl: presigned.presignedUrl, data: data)
        let item = PromotionService.MediaUploadItemDTO(
            mediaLink: presigned.filename,
            mediaType: mediaType,
            main: main
        )
        try await PromotionService.uploadMedia(clubId: clubId, items: [item])
    }

    private func nilIfEmpty(_ s: String) -> String? {
        s.isEmpty ? nil : s
    }

    // MARK: - ISO Datetime Helpers
    // 초 단위는 00으로 고정. 서버 형식: "2025-08-03T14:30:00"

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// "yyyy-MM-dd'T'HH:mm:ss" 형식으로 변환. 초는 항상 00.
    static func formatISO(_ date: Date?) -> String? {
        guard let date else { return nil }
        // 분까지만 추출 (초 = 0)
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        guard let truncated = cal.date(from: comps) else { return nil }
        // ISO formatter는 timezone 포함 → 서버 형식에 맞춰 직접 포매팅
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: truncated)
    }

    /// ISO datetime 문자열 → Date 파싱. 형식 다양성 허용.
    static func parseISO(_ s: String?) -> Date? {
        guard let s, !s.isEmpty else { return nil }
        // 1차: 서버 형식 (timezone 없음)
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "en_US_POSIX")
        if let d = f.date(from: s) { return d }
        // 2차: ISO8601 with timezone
        if let d = isoFormatter.date(from: s) { return d }
        return nil
    }
}
