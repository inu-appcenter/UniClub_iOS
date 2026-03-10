//
//  HTTPClient+PUT.swift
//  UniClub
//
//  Created by 제욱 on 2/11/26.
//
import Foundation

extension HTTPClient {

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

            guard let http = resp as? HTTPURLResponse else {
                throw APIError.badResponse(-1, "Invalid HTTPURLResponse")
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: respData, encoding: .utf8) ?? ""
                throw APIError.badResponse(http.statusCode, body)
            }
        } catch let e as URLError {
            throw APIError.transport(e)
        } catch {
            throw APIError.unknown(error)
        }
    }
}
