import Foundation

struct MajorItem: Identifiable, Hashable {
    var id: String { code }
    let code: String
    let display: String
}

struct MajorSection: Identifiable {
    let id: String
    let title: String
    let items: [MajorItem]
}

struct MajorColumnPair: Identifiable {
    let id: String
    let left: MajorSection
    let right: MajorSection
}
