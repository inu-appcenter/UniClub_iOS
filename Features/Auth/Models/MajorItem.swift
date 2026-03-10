//
//  MajorItem.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//

import Foundation

struct MajorItem: Identifiable, Hashable {
    var id: String { code }
    let code: String     // 서버 전송값: "COMPUTER_ENGINEERING"
    let display: String  // 표시값: "컴퓨터공학부"
}
