//
//  AppTab.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

public enum AppTab: Hashable {
    case qna
    case home
    case mypage

    public var title: String {
        switch self {
        case .qna: return "질의응답"
        case .home: return "홈"
        case .mypage: return "마이페이지"
        }
    }

    public func navIconAssetName(isSelected: Bool) -> String {
        switch self {
        case .qna:
            return isSelected ? "icon_navigation_question_on" : "icon_navigation_question_off"
        case .home:
            return isSelected ? "icon_navigation_home_on" : "icon_navigation_home_off"
        case .mypage:
            return isSelected ? "icon_navigation_my_on" : "icon_navigation_my_off"
        }
    }
}
