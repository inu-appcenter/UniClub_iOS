
//
//  HTTPClient.swift
//  UniClub
//
//  Created by 제욱 on 8/31/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case badURL
    case badResponse(Int, String)
    case decoding(Error)
    case transport(URLError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "잘못된 URL입니다."
        case .badResponse(let code, let body): return "[HTTP \(code)] \(body)"
        case .decoding(let err): return "Decoding error: \(err)"
        case .transport(let err): return "Network error: \(err)"
        case .unknown(let err): return "Unknown error: \(err)"
        }
    }
}

final class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    
    // ✅ 쿠키/세션 유지용
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpShouldSetCookies = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
    
    var authTokenProvider: () -> String? = { MyAuthStore.shared.accessToken }
    
    // ✅ 공개 API용 (Authorization 절대 주입 X)
    func sendWithoutAuth(_ request: URLRequest) async throws -> (Data, URLResponse) {
        var req = request
        req.setValue(nil, forHTTPHeaderField: "Authorization")
        return try await session.data(for: req)
    }
    
    
    
    // MARK: - Public GET helpers
    
    func get<T: Decodable>(
        _ path: String,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:],
        as: T.Type = T.self
    ) async throws -> T {
        let data = try await getRaw(path, query: query, headers: headers)
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw APIError.decoding(error) }
    }
    
    func getFlexibleArray<T: Decodable>(
        _ path: String,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:],
        as: T.Type = T.self
    ) async throws -> [T] {
        let data = try await getRaw(path, query: query, headers: headers)
        let dec = JSONDecoder()
        if let arr = try? dec.decode([T].self, from: data) { return arr }
        let one = try dec.decode(T.self, from: data)
        return [one]
    }
    
    /// 4-3에서 쓸 수 있는 기반이지만, 4-1 단계에서는 유지해도 됨
    func withAuthRetry<T>(
        _ work: @escaping () async throws -> T,
        onUnauthorized: @escaping () async throws -> Void
    ) async throws -> T {
        do { return try await work() }
        catch APIError.badResponse(let status, _) where status == 401 {
            try await onUnauthorized()
            return try await work()
        }
    }
    
    // MARK: - Core raw request (GET)
    
    func getRaw(
        _ path: String,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) async throws -> Data {
        let url = try makeURL(path, query: query)
        
        var req = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // ✅ (4-1) Authorization 주입은 HTTPClient에서만 수행
        // ✅ 단, 이미 외부에서 Authorization을 붙였으면 덮어쓰지 않음
        injectAuthorizationIfNeeded(into: &req)
        
        // 외부에서 넘긴 헤더 적용 (이 시점에 Authorization을 넘겨주면 그대로 유지됨)
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        do {
            let (data, resp) = try await session.data(for: req)
            log(req, data: data, resp: resp)
            
            guard let http = resp as? HTTPURLResponse else {
                throw APIError.badResponse(-1, "Invalid HTTPURLResponse")
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: data, encoding: .utf8) ?? ""
                
                // ✅ (4-3 A안) 401이면 즉시 로그아웃 처리(토큰 삭제)
                if http.statusCode == 401 {
                    await MainActor.run {
                        MyAuthStore.shared.signOut()
                    }
                }
                
                
                throw APIError.badResponse(http.statusCode, body)
            }
            return data
        } catch let urlErr as URLError {
            throw APIError.transport(urlErr)
        } catch {
            throw APIError.unknown(error)
        }
    }
    
    /// ✅ (4-1) 이미 만들어진 URLRequest를 받아서
    /// Authorization이 없으면 자동 주입한 뒤 URLSession을 실행한다.
    /// - "상태코드 체크 / 디코딩"은 호출한 서비스가 기존대로 처리하게 둔다 (변경 최소)
    func sendRaw(_ request: URLRequest, requiresAuth: Bool = true) async throws -> (Data, URLResponse) {
        var req = request
        
        // ✅ (핵심) requiresAuth가 true일 때만 Authorization 자동 주입
        if requiresAuth,
           req.value(forHTTPHeaderField: "Authorization") == nil,
           let token = authTokenProvider(), !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, resp) = try await session.data(for: req)
            log(req, data: data, resp: resp)
            
            // ✅ 401 signOut은 "인증 요청"에만 적용하는 게 자연스러움
            if requiresAuth,
               let http = resp as? HTTPURLResponse,
               http.statusCode == 401 {
                await MainActor.run { MyAuthStore.shared.signOut() }
            }
            
            return (data, resp)
        } catch let urlErr as URLError {
            throw APIError.transport(urlErr)
        } catch {
            throw APIError.unknown(error)
        }
    }
    
    
    
    
    // MARK: - Authorization Injection (4-1 핵심)
    
    /// Authorization 헤더가 없다면, authTokenProvider로부터 토큰을 받아 Bearer 토큰을 주입한다.
    /// - 중요: 이미 Authorization이 있으면 "절대 덮어쓰지 않는다"
    func injectAuthorizationIfNeeded(into request: inout URLRequest) {
        // 이미 Authorization이 세팅되어 있으면 건드리지 않는다 (Feature/테스트 코드 호환)
        if request.value(forHTTPHeaderField: "Authorization") != nil {
            return
        }
        
        // 토큰이 있으면 주입
        if let token = authTokenProvider(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    // MARK: - URL builder
    
    func makeURL(_ path: String, query: [URLQueryItem]?) throws -> URL {
        guard var url = URL(string: AppConfig.baseURL.absoluteString + (path.hasPrefix("/") ? path : "/" + path)) else {
            throw APIError.badURL
        }
        if let query, var comp = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            comp.queryItems = query
            if let u = comp.url { url = u }
        }
        return url
    }
    
    // MARK: - Debug log
    
    // HTTPClient.swift
    
    func log(_ req: URLRequest, data: Data?, resp: URLResponse?) {
#if DEBUG
        print("➡️ \(req.httpMethod ?? "-") \(req.url?.absoluteString ?? "-")")
        print("➡️ Headers:", req.allHTTPHeaderFields ?? [:])
        
        if let body = req.httpBody, let s = String(data: body, encoding: .utf8) {
            print("➡️ Body:", s)
        }
        
        if let http = resp as? HTTPURLResponse {
            print("⬅️ Status:", http.statusCode)
            print("⬅️ Resp Headers:", http.allHeaderFields)
        }
        
        if let data, let s = String(data: data, encoding: .utf8) {
            print("⬅️ Response Body:", s)
        }
#endif
    }
}
