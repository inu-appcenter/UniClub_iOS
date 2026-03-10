import SwiftUI

struct CollectMajorGraduateView: View {
    @Environment(\.appMetrics) private var m

    let onBack: () -> Void
    let onSelect: (MajorItem) -> Void

    private var graduate: [MajorItem] {
        MajorCatalog.all.filter { item in
            item.code.contains("_DEPARTMENT") || item.code.contains("_MAJOR")
        }
    }

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: m.space10) {
                ForEach(graduate) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        HStack {
                            Text(item.display)
                                .font(AppTypography.body())
                                .foregroundStyle(AppColors.textPrimary)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, m.space12)
                        .padding(.vertical, m.space12)
                        .background(AppColors.cardFill)
                        .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                        .overlay(
                            RoundedRectangle(cornerRadius: m.radius18)
                                .stroke(AppColors.border, lineWidth: m.hairline)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: 420)
    }
}
