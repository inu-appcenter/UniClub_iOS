import Foundation
import Combine

@MainActor
final class MyAuthStore: ObservableObject {
    static let shared = MyAuthStore()
    private init() {
        loadFromKeychainOrMigrate()
    }

    // MARK: - Keys (UserDefaults legacy 포함)
    private let accessKey = "uniclub.auth.accessToken"   // 기존 UserDefaults 키
    private let legacyAccessKey = "userAuthToken"        // TokenManager가 쓰던 기존 키

    // ✅ Keychain 식별자 (bundle id 기반이 가장 안전)
    private let keychainService = Bundle.main.bundleIdentifier ?? "UniClub"
    private let keychainAccount = "uniclub.auth.accessToken"

    /// Bearer 접두사 없는 순수 토큰 문자열
    @Published private(set) var accessToken: String? {
        didSet { saveToKeychain() }
    }

    // MARK: - Public API
    func setAccessToken(_ token: String?) {
        let trimmed = token?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let t = trimmed, !t.isEmpty {
            accessToken = t
        } else {
            accessToken = nil
        }
    }

    func signOut() {
        setAccessToken(nil)
    }

    /// HTTP Authorization 헤더에 넣기 좋은 형태가 필요할 때 사용
    var bearerToken: String? {
        guard let t = accessToken, !t.isEmpty else { return nil }
        return "Bearer \(t)"
    }

    // MARK: - Keychain Persistence
    private func saveToKeychain() {
        if let token = accessToken, !token.isEmpty {
            KeychainStore.upsert(token, service: keychainService, account: keychainAccount)
        } else {
            KeychainStore.delete(service: keychainService, account: keychainAccount)
        }
    }

    private func loadFromKeychainOrMigrate() {
        // 1) Keychain 우선
        if let token = KeychainStore.read(service: keychainService, account: keychainAccount),
           !token.isEmpty {
            accessToken = token
            return
        }

        // 2) UserDefaults(신규 키) → Keychain 마이그레이션
        let ud = UserDefaults.standard
        if let udToken = ud.string(forKey: accessKey), !udToken.isEmpty {
            accessToken = udToken
            KeychainStore.upsert(udToken, service: keychainService, account: keychainAccount)
            ud.removeObject(forKey: accessKey)
            return
        }

        // 3) UserDefaults(레거시 키) → Keychain 마이그레이션
        if let legacy = ud.string(forKey: legacyAccessKey), !legacy.isEmpty {
            accessToken = legacy
            KeychainStore.upsert(legacy, service: keychainService, account: keychainAccount)
            ud.removeObject(forKey: legacyAccessKey)
            return
        }

        accessToken = nil
    }

    // MARK: - Refresh (출시 시 실제 구현으로 교체)
    @discardableResult
    func refreshIfNeeded() async throws -> String? {
        return accessToken
    }
}
