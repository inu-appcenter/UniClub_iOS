import SwiftUI

struct CollectMajorListView: View {
    @Environment(\.appMetrics) private var m

    let onTapGraduate: () -> Void
    let onSelect: (MajorItem) -> Void

    // ✅ 학부 리스트: “대학원 전용” 코드들을 대충 걸러냄(필요하면 규칙 더 조정)
    private var undergrad: [MajorItem] {
        MajorCatalog.all.filter { item in
            // 대충 대학원 느낌 코드들 제외(원하면 더 추가)
            !item.code.contains("_DEPARTMENT")
            && !item.code.contains("_MAJOR")
        }
    }

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: m.space10) {

                // ✅ “대학원생” 진입 버튼
                Button {
                    onTapGraduate()
                } label: {
                    row(title: "대학원생", isChevron: true)
                }
                .buttonStyle(.plain)

                ForEach(undergrad) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        row(title: item.display, isChevron: false)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: 420)
    }

    private func row(title: String, isChevron: Bool) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Image(systemName: isChevron ? "chevron.right" : "checkmark")
                .opacity(isChevron ? 0.6 : 0.0)
                .foregroundStyle(AppColors.textSecondary)
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
}
