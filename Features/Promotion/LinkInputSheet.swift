import SwiftUI

struct LinkInputSheet: View {
    @Environment(\.appMetrics) private var m
    @Environment(\.dismiss) private var dismiss

    let title: String
    @Binding var url: String

    @State private var draft: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(AppTypography.notoSans(14, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button("완료") {
                    url = draft
                    dismiss()
                }
                .font(AppTypography.notoSans(14, weight: .medium))
                .foregroundStyle(AppColors.brand)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, m.space20)
            .padding(.top, m.space20)
            .padding(.bottom, m.space16)

            VStack(alignment: .leading, spacing: m.space6) {
                Text("URL")
                    .font(AppTypography.notoSans(10, weight: .bold))
                    .foregroundStyle(AppColors.brand)

                TextField("https://", text: $draft)
                    .font(AppTypography.notoSans(13))
                    .foregroundStyle(AppColors.textPrimary)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, m.space14)
                    .frame(height: m.space44)
                    .background(AppColors.fieldFill)
                    .clipShape(RoundedRectangle(cornerRadius: m.radius12))
                    .overlay(
                        RoundedRectangle(cornerRadius: m.radius12)
                            .stroke(AppColors.brand, lineWidth: 1)
                    )
            }
            .padding(.horizontal, m.space20)

            Spacer()
        }
        .onAppear { draft = url }
        .presentationDetents([.height(200)])
    }
}
