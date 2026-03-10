


import SwiftUI

struct MajorPickerSheetView: View {
    @Environment(\.appMetrics) private var m

    @Binding var isPresented: Bool
    @State private var step: MajorPickerStep = .list

    let onSelectMajor: (MajorItem) -> Void
    
    var body: some View {
        if isPresented {
            ZStack(alignment: .bottom) {

                // dim background
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }

                // bottom sheet card
                VStack(spacing: 0) {
                    sheetHeader

                    Divider()
                        .opacity(0.15)

                    Group {
                        switch step {
                        case .list:
                            CollectMajorListView(
                                onTapGraduate: { step = .graduate },
                                onSelect: { major in
                                    onSelectMajor(major)
                                    isPresented = false
                                }
                            )
                        case .graduate:
                            CollectMajorGraduateView(
                                onBack: { step = .list },
                                onSelect: { major in
                                    onSelectMajor(major)
                                    isPresented = false
                                }
                            )
                        }
                    }
                    .padding(.top, m.space12)
                    .padding(.bottom, m.space18)
                    .padding(.horizontal, m.space12)
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.background)
                .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                .padding(.horizontal, m.space12)
                .padding(.bottom, m.space12)
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: isPresented)
        }
    }

    private var sheetHeader: some View {
        HStack(spacing: m.space10) {
            // step별 뒤로
            if step == .graduate {
                Button {
                    step = .list
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            } else {
                Spacer().frame(width: 44, height: 44)
            }

            Text(step == .list ? "학과 선택" : "대학원생")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, m.space6Or8Fallback)
        .padding(.vertical, m.space8)
    }
}

private extension AppMetrics {
    /// m.space6가 없을 수 있어서 안전하게
    var space6Or8Fallback: CGFloat { 8 }
}
