//
//  KeyboardAvoiding.swift
//  UniClub
//
//  Created by 제욱 on 2/8/26.
//

import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit

private final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willChange = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

        Publishers.Merge(willShow, willChange)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .receive(on: RunLoop.main)
            .sink { [weak self] h in self?.height = h }
            .store(in: &cancellables)

        willHide
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.height = 0 }
            .store(in: &cancellables)
    }
}

private struct KeyboardAvoidingModifier: ViewModifier {
    @StateObject private var keyboard = KeyboardObserver()

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboard.height)
            .animation(.easeOut(duration: 0.2), value: keyboard.height)
    }
}

extension View {
    func keyboardAvoiding() -> some View {
        modifier(KeyboardAvoidingModifier())
    }
}
#else
extension View {
    func keyboardAvoiding() -> some View {
        self
    }
}
#endif
