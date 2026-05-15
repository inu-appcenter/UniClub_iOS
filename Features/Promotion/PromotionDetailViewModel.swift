import Foundation
import Combine

@MainActor
final class PromotionDetailViewModel: ObservableObject {

    @Published private(set) var promotion: PromotionService.ClubPromotionDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFavorite = false
    @Published var isTogglingFavorite = false

    private let clubId: Int

    init(clubId: Int) {
        self.clubId = clubId
    }

    // MARK: - Derived

    var backgroundURL: URL? {
        promotion?.mediaList.first(where: { $0.mediaType == .clubBackground })?.url
    }

    var profileURL: URL? {
        promotion?.mediaList.first(where: { $0.mediaType == .clubProfile })?.url
    }

    var promotionImages: [PromotionService.MediaDTO] {
        promotion?.mediaList.filter { $0.mediaType == .clubPromotion } ?? []
    }

    var canEdit: Bool {
        promotion?.role == "ADMIN" || promotion?.role == "PRESIDENT"
    }

    var statusText: String {
        switch promotion?.status {
        case "ACTIVE":    return "모집중"
        case "CLOSED":    return "모집마감"
        case "SCHEDULED": return "모집예정"
        default:          return promotion?.status ?? ""
        }
    }

    var recruitPeriod: String? {
        switch (promotion?.startTime, promotion?.endTime) {
        case (let s?, let e?): return "\(s) ~ \(e)"
        case (let s?, nil):    return s
        case (nil, let e?):    return e
        default:               return nil
        }
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let dto = try await PromotionService.fetchPromotion(clubId: clubId)
            promotion = dto
            isFavorite = dto.favorite
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    func toggleFavorite() async {
        guard !isTogglingFavorite else { return }
        isTogglingFavorite = true
        isFavorite.toggle()
        do {
            _ = try await PromotionService.toggleFavorite(clubId: clubId)
        } catch {
            isFavorite.toggle()
        }
        isTogglingFavorite = false
    }
}
