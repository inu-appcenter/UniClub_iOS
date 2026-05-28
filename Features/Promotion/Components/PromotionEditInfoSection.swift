import SwiftUI

struct PromotionEditInfoSection: View {
    @Environment(\.appMetrics) private var m
    @ObservedObject var vm: PromotionEditViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            clubInfoBlock
                .padding(.top, m.space14)

            taglineFieldStrip
                .padding(.top, m.scale * 25)

            recruitNoticeBlock
                .padding(.top, m.space32)
        }
    }

    // MARK: - Club Info Block

    private var clubInfoBlock: some View {
        VStack(alignment: .leading, spacing: m.space12) {
            HStack(spacing: -m.space8) {
                Text(vm.name)
                    .font(AppTypography.notoSans(13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, m.space14)
                    .frame(height: m.scale * 30)
                    .background(AppColors.brand)
                    .clipShape(Capsule())

                Button { vm.cycleStatus() } label: {
                    HStack(spacing: m.space4) {
                        Text(vm.statusText)
                            .font(AppTypography.notoSans(10))
                            .foregroundStyle(.white)
                        Image(systemName: "arrow.clockwise")
                            .font(AppTypography.notoSans(9))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, m.space10)
                    .frame(height: m.space18)
                    .background(statusBadgeColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .zIndex(1)
            }

            HStack(spacing: m.space24) {
                miniEditField("동아리방", text: $vm.location)
                miniEditField("회장",    text: $vm.presidentName)
                miniEditField("연락처",  text: $vm.presidentPhone)
            }
        }
    }

    private var statusBadgeColor: Color {
        switch vm.status {
        case "CLOSED", "SCHEDULED": return AppColors.grey400
        default:                    return Color(hex: 0x353535)
        }
    }

    // MARK: - Tagline

    private var taglineFieldStrip: some View {
        TextField("동아리를 한 줄로 표현해보세요", text: $vm.simpleDescription)
            .font(AppTypography.notoSans(10, weight: .bold))
            .foregroundStyle(AppColors.brand)
            .padding(.leading, m.scale * 33)
            .padding(.top, m.space12)
            .padding(.bottom, m.space8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.background)
            .shadow(
                color: Color(hex: 0x999999).opacity(0.19),
                radius: m.scale * 17,
                x: m.space14,
                y: m.space2
            )
            .padding(.horizontal, -m.space28)
    }

    // MARK: - Recruit / Notice

    private var recruitNoticeBlock: some View {
        VStack(alignment: .leading, spacing: m.space12) {
            dateRow("모집 시작", date: $vm.startDate)
            dateRow("모집 종료", date: $vm.endDate)
            editRow("공지", text: $vm.notice, placeholder: "공지 내용을 입력하세요")
        }
    }

    private func dateRow(_ label: String, date: Binding<Date?>) -> some View {
        HStack(alignment: .center, spacing: m.space18) {
            Text(label)
                .font(AppTypography.notoSans(10, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: m.scale * 40, alignment: .leading)

            DatePicker(
                "",
                selection: Binding(
                    get: { date.wrappedValue ?? Date() },
                    set: { date.wrappedValue = $0 }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(AppColors.brand)
            .scaleEffect(0.75, anchor: .leading)
            .frame(height: 24)
            .clipped()
        }
    }

    private func miniEditField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: m.space2) {
            Text(label)
                .font(AppTypography.notoSans(10, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            TextField(label, text: text)
                .font(AppTypography.notoSans(9))
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    private func editRow(_ label: String, text: Binding<String>, placeholder: String? = nil) -> some View {
        HStack(alignment: .center, spacing: m.space18) {
            Text(label)
                .font(AppTypography.notoSans(10, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: m.scale * 40, alignment: .leading)

            TextField(placeholder ?? label, text: text)
                .font(AppTypography.notoSans(10, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
