
//
//  UniClubAPI.swift
//  UniClub
//
//  통합: Main API + Clubs API + 공통 HTTPClient/에러/유틸
//
import Foundation

enum AppConfig {
    static let baseURL = URL(string: "https://uniclub-server.inuappcenter.kr")!
    
    enum API {
        // MARK: - Auth
        enum Auth {
            static let login = "/api/v1/auth/login"
            static let verifyStudent = "/api/v1/auth/register/student-verification"
            static let register = "/api/v1/auth/register"
        }

        // MARK: - Clubs
        enum Clubs {
            static let list = "/api/v1/clubs"
            static func detail(_ id: Int) -> String {
                "/api/v1/clubs/\(id)"
            }
        }

        // MARK: - Main
        enum Main {
            static let banner = "/api/v1/main/banner"
            static let clubs  = "/api/v1/main/clubs"
        }

        // MARK: - QnA
        enum Qna {
            static let search = "/api/v1/qna/search"
            static func detail(_ id: Int) -> String {
                "/api/v1/qna/\(id)"
            }
            static func answers(_ id: Int) -> String {
                "/api/v1/qna/\(id)/answers"
            }
            static let searchclubs = "/api/v1/qna/search-clubs"
            
            static let questions = "/api/v1/qna/{questionId}"
        }

        // MARK: - mypage
        enum User {
            static let me = "/api/v1/users/me"
            static let edit = "/api/v1/users/me"
            static let delete = "/api/v1/users"
            static let profilePresigned = "/api/v1/user/profile/s3-presigned"
        }
    }
}
