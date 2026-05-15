//
//  MyPageViewModel.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import Foundation
import Combine

@MainActor
final class MyPageViewModel: ObservableObject {

    // ✅ View에는 UI 모델만 노출
    @Published private(set) var profileUI: MyPageProfileUI? = nil

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var didInitialLoad: Bool = false
    private var meDTO: UserMeResponse? = nil

    func load(force: Bool) async {
        if didInitialLoad, !force { return }
        didInitialLoad = true

        isLoading = true
        errorMessage = nil
        do {
            let dto = try await UserService.me()
            meDTO = dto
            profileUI = MyPageProfileUI.from(dto)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        await load(force: true)
    }

    func signOut() {
        Task { await MyAuthStore.shared.signOut() }
    }
}
