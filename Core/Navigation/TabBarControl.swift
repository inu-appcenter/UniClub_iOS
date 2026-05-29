import SwiftUI

struct TabBarPresencePreferenceKey: PreferenceKey {
    static var defaultValue: Bool = true
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value && nextValue()
    }
}

extension View {
    func tabBarPresent(_ present: Bool) -> some View {
        preference(key: TabBarPresencePreferenceKey.self, value: present)
    }
}
