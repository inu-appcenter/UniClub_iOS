//
//  HTTPClient+PATCH:DELETE.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import Foundation

// MARK: - PATCH / DELETE (JSON Body)

extension HTTPClient {

    /// ✅ PATCH(JSON) + Raw(Data, HTTPURLResponse)
    func patchJSONRaw<Body: Encodable>(
        _ path: String,
        body: Body,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) async throws -> (Data, HTTPURLResponse) {

        let url = try makeURL(path, query: query)

        var req = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        injectAuthorizationIfNeeded(into: &req)
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        req.httpBody = try JSONEncoder().encode(body)

        return try await performRaw(req)
    }

    /// ✅ DELETE(JSON) + Raw(Data, HTTPURLResponse)
    func deleteJSONRaw<Body: Encodable>(
        _ path: String,
        body: Body,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) async throws -> (Data, HTTPURLResponse) {

        let url = try makeURL(path, query: query)

        var req = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        injectAuthorizationIfNeeded(into: &req)
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        req.httpBody = try JSONEncoder().encode(body)

        return try await performRaw(req)
    }

    /// ✅ PATCH(body 없음) + Raw(Data, HTTPURLResponse)
    func patchRaw(
        _ path: String,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) async throws -> (Data, HTTPURLResponse) {

        let url = try makeURL(path, query: query)

        var req = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        injectAuthorizationIfNeeded(into: &req)
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }

        return try await performRaw(req)
    }

    /// ✅ DELETE(body 없음) + Raw(Data, HTTPURLResponse)
    func deleteRaw(
        _ path: String,
        query: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) async throws -> (Data, HTTPURLResponse) {

        let url = try makeURL(path, query: query)

        var req = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        injectAuthorizationIfNeeded(into: &req)
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }

        return try await performRaw(req)
    }

    private func performRaw(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, resp) = try await sendRaw(request, requiresAuth: true)

            guard let http = resp as? HTTPURLResponse else {
                throw APIError.badResponse(-1, "Invalid HTTPURLResponse")
            }

            guard (200...299).contains(http.statusCode) else {
                let bodyStr = String(data: data, encoding: .utf8) ?? ""
                throw APIError.badResponse(http.statusCode, bodyStr)
            }

            return (data, http)
        } catch let e as URLError {
            throw APIError.transport(e)
        } catch {
            throw APIError.unknown(error)
        }
    }
}
