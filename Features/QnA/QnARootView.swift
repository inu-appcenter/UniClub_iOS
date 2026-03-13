//
//  QnARootView.swift
//  UniClub
//
//  Created by 제욱 on 3/11/26.
//

import SwiftUI

struct QnARootView: View {
    @Binding var path: NavigationPath
    let onBackToHome: () -> Void

    var body: some View {
        QnAListView(
            onBackToHome: onBackToHome,
            onOpenDetail: { questionId in
                path.append(QnARoute.detail(questionId: questionId))
            },
            onOpenComposer: { selectedClub in
                path.append(QnARoute.compose(selectedClub: selectedClub))
            }
        )
        .navigationDestination(for: QnARoute.self) { route in
            switch route {
            case .detail(let questionId):
                QnADetailView(
                    questionId: questionId,
                    onBack: {
                        if !path.isEmpty { path.removeLast() }
                    },
                    onCloseToHome: onBackToHome,
                    onEdit: { questionId, club, content in
                        path.append(QnARoute.edit(questionId: questionId, club: club, initialContent: content))
                    }
                )

            case .compose(let selectedClub):
                QnAComposerView(
                    selectedClub: selectedClub,
                    onDismiss: {
                        if !path.isEmpty { path.removeLast() }
                    }
                )

            case .edit(let questionId, let club, let initialContent):
                QnAComposerView(
                    questionId: questionId,
                    selectedClub: club,
                    initialContent: initialContent,
                    onDismiss: {
                        if !path.isEmpty { path.removeLast() }
                    }
                )
            }
        }
    }
}
