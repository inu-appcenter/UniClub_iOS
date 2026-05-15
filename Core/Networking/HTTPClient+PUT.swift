//
//  HTTPClient+PUT.swift
//  UniClub
//
//  Created by 제욱 on 2/11/26.
//
import Foundation

extension HTTPClient {

    /// ✅ PUT(JSON) + Decodable response
    func putJSON<Body: Encodable, Res: Decodable>(
        _ path: String,
        body: Body,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:],
        as: Res.Type = Res.self
    ) async throws -> Res {
        let url = try makeURL(path, query: query)
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        let (data, _) = try await sendValidatedRaw(req)
        return try decode(Res.self, from: data)
    }

    /// ✅ PUT(JSON) + Raw(Data, HTTPURLResponse) — 204 No Content 대응
    func putJSONRaw<Body: Encodable>(
        _ path: String,
        body: Body,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) async throws -> (Data, HTTPURLResponse) {
        let url = try makeURL(path, query: query)
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        return try await sendValidatedRaw(req)
    }

    /// ✅ presignedUrl(S3)에 PUT 업로드 (Authorization 절대 X)
    func putBinary(to absoluteURL: URL, data: Data, contentType: String) async throws {
        var req = URLRequest(url: absoluteURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        req.httpMethod = "PUT"
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        req.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")

        // ✅ 절대 토큰 붙이면 안 됨 (S3 presigned는 쿼리로 인증)
        req.setValue(nil, forHTTPHeaderField: "Authorization")

        do {
            let (respData, resp) = try await URLSession.shared.upload(for: req, from: data)
            log(req, data: respData, resp: resp)

            _ = try validate(data: respData, response: resp)
        } catch let apiError as APIError {
            throw apiError
        } catch let e as URLError {
            throw APIError.transport(e)
        } catch {
            throw APIError.unknown(error)
        }
    }
}
