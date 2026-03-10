//
//  MajorCodeMapper.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//

import Foundation

enum MajorCodeMapper {
    static func toCode(display: String) -> String {
        switch display {
        case "컴퓨터공학과", "컴퓨터공학부", "컴퓨터공학전공":
            return "COMPUTER_ENGINEERING"
        // 너희 학교/서버 enum에 맞춰 계속 추가
        default:
            return "" // 매핑 못하면 빈값 -> Step1에서 Next 못누르게 됨
        }
    }
}
