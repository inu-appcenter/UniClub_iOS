import SwiftUI

struct EditProfileFieldsBlock: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: EditProfileViewModel
    let onTapMajor: () -> Void
    let isMajorSheetVisible: Bool

    private enum Field {
        case name
        case nickname
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 15 * m.scale) {
            majorRow
            labeledInputRow(title: "이름", text: $vm.name, field: .name)
            labeledInputRow(title: "닉네임", text: $vm.nickname, field: .nickname)
        }
        .padding(.horizontal, 30 * m.scale)
    }

    private func labeledInputRow(
        title: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        HStack(alignment: .center, spacing: m.space14) {
            Text(title)
                .font(AppTypography.notoSans(12))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 50 * m.scale, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: m.radius14, style: .continuous)
                    .fill(AppColors.fieldFill)
                    .frame(height: 31)

                TextField("", text: text)
                    .focused($focusedField, equals: field)
                    .font(AppTypography.notoSans(12))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, m.space14)
                    .frame(height: 31)
            }
            .frame(width: 196 * m.scale, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: m.radius14, style: .continuous)
                    .stroke(
                        focusedField == field ? AppColors.brand : .clear,
                        lineWidth: focusedField == field ? 0.5 : 0
                    )
            )
        }
    }

    private var majorRow: some View {
        HStack(alignment: .center, spacing: m.space14) {
            Text("학과")
                .font(AppTypography.notoSans(12))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 50 * m.scale, alignment: .leading)

            Button(action: onTapMajor) {
                HStack(spacing: m.space8) {
                    Text(vm.majorDisplay.isEmpty ? "학과 선택" : vm.majorDisplay)
                        .font(AppTypography.notoSans(12))
                        .foregroundStyle(vm.majorDisplay.isEmpty ? AppColors.textSecondary : AppColors.textPrimary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(AppTypography.notoSans(12, weight: .semibold))
                        .foregroundStyle(isMajorSheetVisible ? AppColors.brand : AppColors.grey600)
                }
                .padding(.horizontal, m.space14)
                .frame(width: 196 * m.scale, height: 31)
                .background(AppColors.fieldFill)
                .clipShape(RoundedRectangle(cornerRadius: m.radius14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: m.radius14, style: .continuous)
                        .stroke(
                            isMajorSheetVisible ? AppColors.brand : .clear,
                            lineWidth: isMajorSheetVisible ? 0.5 : 0
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}
