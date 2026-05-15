//
//  NotificationViewModel.swift
//  UniClub

import Foundation
import Combine

@MainActor
final class NotificationViewModel: ObservableObject {
    @Published private(set) var items: [NotificationItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    var unread: [NotificationItem] { items.filter { !$0.isRead } }
    var read:   [NotificationItem] { items.filter {  $0.isRead } }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await NotificationService.fetchAll()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    func markRead(item: NotificationItem) async {
        guard !item.isRead else { return }
        // 낙관적 업데이트
        updateItem(id: item.id) { $0.isRead = true }
        do {
            try await NotificationService.markRead(id: item.id)
        } catch {
            updateItem(id: item.id) { $0.isRead = false }
        }
    }

    func markAllRead() async {
        let prev = items
        items = items.map { var i = $0; i.isRead = true; return i }
        do {
            try await NotificationService.markAllRead()
        } catch {
            items = prev
        }
    }

    func delete(item: NotificationItem) async {
        let prev = items
        items.removeAll { $0.id == item.id }
        do {
            try await NotificationService.delete(id: item.id)
        } catch {
            items = prev
        }
    }

    func deleteAll(readOnly: Bool = true) async {
        let prev = items
        if readOnly {
            items.removeAll { $0.isRead }
        } else {
            items.removeAll()
        }
        do {
            try await NotificationService.deleteAll()
        } catch {
            items = prev
        }
    }

    private func updateItem(id: Int, mutation: (inout NotificationItem) -> Void) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        mutation(&items[idx])
    }
}
