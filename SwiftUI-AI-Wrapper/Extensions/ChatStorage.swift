//
//  ChatStorage.swift
//  SwiftUI-AI-Wrapper
//
//  Created by Jen Kersh on 7/6/25.
//

import Foundation

class ChatStorage {
    static let shared = ChatStorage()
    private let folderName = "SavedChats"

    private var folderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = docs.appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    func saveChat(_ chat: ChatModel) {
        let fileURL = folderURL.appendingPathComponent("\(chat.id).json")
        do {
            let data = try JSONEncoder().encode(chat)
            try data.write(to: fileURL)
        } catch {
            print("❌ Failed to save chat: \(error)")
        }
    }

    func loadChats() -> [ChatModel] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            return files.compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(ChatModel.self, from: data)
            }.sorted(by: { $0.date > $1.date })
        } catch {
            print("❌ Failed to load chats: \(error)")
            return []
        }
    }

    func deleteChat(_ chat: ChatModel) {
        let fileURL = folderURL.appendingPathComponent("\(chat.id).json")
        try? FileManager.default.removeItem(at: fileURL)
    }
}
