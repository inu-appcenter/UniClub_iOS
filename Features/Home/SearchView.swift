//
//  SearchView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

/// Home_Tap_검색화면 + Home_Tap_검색어입력시 → 한 화면의 상태(query empty/non-empty)로 커버
struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""

    var body: some View {
        ScreenContainer(scroll: true) { m in
            VStack(alignment: .leading, spacing: 0) {

                // 검색 바
                HStack(spacing: m.space10) {
                    HStack(spacing: m.space8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppColors.textSecondary)

                        TextField("동아리를 검색해보세요 :D", text: $query)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        if !query.isEmpty {
                            Button {
                                query = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, m.space12)
                    .padding(.vertical, m.space10)
                    .background(Color(hex: 0xD9D9D9))
                    .clipShape(RoundedRectangle(cornerRadius: m.radius18))

                    Button("취소") { dismiss() }
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.textPrimary)
                        .buttonStyle(.plain)
                }
                .padding(.bottom, m.space12)

                // 상태 분기
                if query.isEmpty {
                    // 검색화면 기본 상태(더미)
                    Text("추천 동아리")
                        .font(AppTypography.bodyStrong())
                        .padding(.bottom, m.space12)

                    VStack(spacing: m.space12) {
                        ForEach(0..<6, id: \.self) { idx in
                            ClubCard(
                                name: "추천 동아리 \(idx+1)",
                                statusText: "모집중",
                                imageURL: nil,
                                tags: ["추가정보"]
                            ) { }
                        }
                    }
                } else {
                    // 검색어 입력 상태(더미)
                    Text("“\(query)” 검색 결과")
                        .font(AppTypography.bodyStrong())
                        .padding(.bottom, m.space12)

                    VStack(spacing: m.space12) {
                        ForEach(0..<6, id: \.self) { idx in
                            ClubCard(
                                name: "검색 결과 \(idx+1)",
                                statusText: "모집기간이 아님",
                                imageURL: nil,
                                tags: ["추가정보"]
                            ) { }
                        }
                    }
                }

                Spacer(minLength: m.space24)
            }
        }
        .navigationBarHidden(true) // JSON이 커스텀 검색바를 쓰는 느낌이라 기본 네비게이션 숨김
    }
}
