import SwiftUI

struct PromotionEditDescriptionField: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionEditViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: m.space8) {
            Text("소개글")
                .font(AppTypography.notoSans(10, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            ZStack(alignment: .topLeading) {
                if vm.description.isEmpty {
                    Text("동아리 소개글을 작성해보세요")
                        .font(AppTypography.notoSans(13))
                        .foregroundStyle(AppColors.textTertiary)
                        .padding(.top, m.space8)
                        .padding(.leading, m.space4)
                }
                TextEditor(text: $vm.description)
                    .font(AppTypography.notoSans(13))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(minHeight: m.scale * 120)
                    .scrollContentBackground(.hidden)
            }
            .padding(m.space12)
            .background(AppColors.fieldFill)
            .clipShape(RoundedRectangle(cornerRadius: m.radius12))
        }
    }
}
