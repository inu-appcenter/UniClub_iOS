//
//  HTTPClient+POST.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//

//
//  HTTPClient+POST.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//
 
import Foundation

extension HTTPClient {

    /// ✅ POST(JSON) + Decodable response
    /// - requiresAuth=false : Authorization을 절대 주입하지 않는 공개 API용
    func postJSON<Body: Encodable, Res: Decodable>(
        _ path: String,
        body: Body,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:],
        requiresAuth: Bool = true,
        as: Res.Type = Res.self
    ) async throws -> Res {

        let (data, _) = try await postJSONRaw(
            path,
            body: body,
            query: query,
            headers: headers,
            requiresAuth: requiresAuth
        )

        do {
            return try JSONDecoder().decode(Res.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    /// ✅ POST(JSON) + Raw(Data, HTTPURLResponse)
    /// - 핵심: 여기서 반드시 200~299 상태코드만 통과시키고, 아니면 throw
    func postJSONRaw<Body: Encodable>(
        _ path: String,
        body: Body,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:],
        requiresAuth: Bool = true
    ) async throws -> (Data, HTTPURLResponse) {

        let url = try makeURL(path, query: query)

        var req = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        req.httpBody = try JSONEncoder().encode(body)

        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }

        // ✅ 공개 API면 Authorization 절대 금지
        if !requiresAuth {
            req.setValue(nil, forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let resp: URLResponse

        if requiresAuth {
            (data, resp) = try await sendRaw(req)
        } else {
            // ✅ 공개 API도 같은 session 사용 + Authorization 완전 제거
            (data, resp) = try await sendWithoutAuth(req)
            log(req, data: data, resp: resp)
        }

        guard let http = resp as? HTTPURLResponse else {
            throw APIError.badResponse(-1, "Invalid HTTPURLResponse")
        }

        guard (200...299).contains(http.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            throw APIError.badResponse(http.statusCode, bodyText)
        }

        return (data, http)
    }
}
