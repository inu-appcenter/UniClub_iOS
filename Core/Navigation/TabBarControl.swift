//
//  TabBarControl.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//

import SwiftUI

// MARK: - TabBar 존재 여부 전달 (화면 -> MainShell)
struct TabBarPresencePreferenceKey: PreferenceKey {
    static var defaultValue: Bool = true
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

extension View {
    /// 이 화면에서 탭바가 "존재"해야 하는지 여부를 MainShell에 알림
    func tabBarPresent(_ present: Bool) -> some View {
        preference(key: TabBarPresencePreferenceKey.self, value: present)
    }
}
