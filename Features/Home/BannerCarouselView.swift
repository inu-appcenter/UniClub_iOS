//
//  BannerCarouselView.swift
//  UniClub
//
//  Created by 제욱 on 2/8/26.
//

import SwiftUI
import Combine

struct BannerCarouselView: View {
    @Environment(\.appMetrics) private var m

    @State private var items: [HomeBannerItem] = []
    @State private var selectedID: String = ""
    @State private var isActive = true
    @State private var loadError: String?

    // Figma 기준: 324×249 (가로/세로 비율)
    private let bannerAspect: CGFloat = 324.0 / 249.0

    var body: some View {
        BannerSizeReader(aspect: bannerAspect) { width, height in
            ZStack {
                if items.isEmpty {
                    RoundedRectangle(cornerRadius: m.radius18, style: .continuous)
                        .fill(AppColors.fieldFill)
                        .frame(width: width, height: height)
                        .overlay {
                            if let loadError {
                                Text(loadError)
                                    .font(AppTypography.caption())
                                    .foregroundStyle(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(m.space12)
                            }
                        }
                } else {
                    TabView(selection: $selectedID) {
                        ForEach(items) { item in
                            AsyncImage(url: item.mediaLink) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                case .empty:
                                    AppColors.fieldFill
                                case .failure:
                                    AppColors.fieldFill.opacity(0.7)
                                @unknown default:
                                    AppColors.fieldFill
                                }
                            }
                            .frame(width: width, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: m.radius18, style: .continuous))
                            .tag(item.id) // ✅ 한 번만
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(width: width, height: height)
                }
            }
            .frame(width: width, height: height)
        }
        .task { await load() }
        .onAppear { isActive = true }
        .onDisappear { isActive = false }

        // ✅ items가 채워지는 순간 selection을 “유효한 값”으로 고정
        .onChange(of: items.count) { _ in
            guard !items.isEmpty else {
                selectedID = ""
                return
            }
            let ids = items.map(\.id)
            if !ids.contains(selectedID) {
                selectedID = ids.first ?? ""
            }
        }

        // ✅ 3초마다 다음으로
        .onReceive(Timer.publish(every: 3, on: .main, in: .common).autoconnect()) { _ in
            guard isActive else { return }
            advance()
        }
    }

    private struct BannerSizeReader<Content: View>: View {
        let aspect: CGFloat
        let content: (CGFloat, CGFloat) -> Content

        init(aspect: CGFloat, @ViewBuilder content: @escaping (CGFloat, CGFloat) -> Content) {
            self.aspect = aspect
            self.content = content
        }

        var body: some View {
            GeometryReader { geo in
                let width = geo.size.width
                let height = width / aspect
                content(width, height)
            }
            // ✅ 핵심: “부모 폭”에 맞춰 높이를 고정
            .aspectRatio(aspect, contentMode: .fit)
        }
    }

    @MainActor
    private func load() async {
        do {
            let result = try await HomeBannerService.fetchBanners()

            // ✅ 서버가 중복 배너를 내려주는 케이스가 있어서,
            // mediaLink(id) 기준으로 "순서 유지 + 중복 제거"
            var seen = Set<String>()
            let unique = result.filter { item in
                seen.insert(item.id).inserted
            }

            self.items = unique
            self.selectedID = unique.first?.id ?? ""
            self.loadError = nil
        } catch {
            self.items = []
            self.selectedID = ""
            self.loadError = "배너를 불러오지 못했습니다."
        }
    }
    
    @MainActor
    private func advance() {
        guard isActive, items.count >= 2 else { return }

        let ids = items.map(\.id)

        // selection이 꼬였으면 첫 번째로 복구
        guard let pos = ids.firstIndex(of: selectedID) else {
            selectedID = ids.first ?? ""
            return
        }

        let next = ids[(pos + 1) % ids.count]  // ✅ 마지막 다음엔 처음으로
        withAnimation(.easeInOut) {
            selectedID = next
        }
    }
}
