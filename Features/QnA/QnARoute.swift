//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import Foundation

enum QnARoute: Hashable {
    case detail(questionId: Int)
    case compose(selectedClub: QnAClubSummary?)
    case edit(questionId: Int, club: QnAClubSummary?, initialContent: String)
}
