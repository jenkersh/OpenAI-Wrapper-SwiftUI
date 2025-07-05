// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import Foundation
import SwiftUI

class ChatModel: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var messages: [ChatMessage] = []
    @Published var isSending: Bool = false
    @Published var title: String? = nil
    @Published var date: Date
    
    //customize the location of the openai_proxy.php script
    //source code for openai_proxy.php available here: https://github.com/adamlyttleapps/OpenAI-Proxy-PHP
    
    private let location = "https://antique-worker.jkersh123.workers.dev"
    
    //create a shared secret key, requests to the server use an md5 hash with the shared secret
    private let sharedSecretKey = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case messages
        case isSending
        case title
        case date
    }

    init(id: UUID = UUID(), messages: [ChatMessage] = [], isSending: Bool = false, title: String? = nil, date: Date = Date()) {
        self.id = id
        self.messages = messages
        self.isSending = isSending
        self.title = title
        self.date = date
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        messages = try container.decode([ChatMessage].self, forKey: .messages)
        isSending = try container.decode(Bool.self, forKey: .isSending)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(messages, forKey: .messages)
        try container.encode(isSending, forKey: .isSending)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
    }
    
    var messageData: String? {
        // Convert ChatModel instance to JSON
        do {
            let jsonData = try JSONEncoder().encode(self.messages)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                return jsonString
            }
        } catch {
            print("Failed to encode ChatModel to JSON: \(error)")
        }
        return nil
    }
        
    
    func sendMessage(role: MessageRole = .user, message: String? = nil, image: UIImage? = nil) {
        appendMessage(role: role, message: message, image: image)
        self.isSending = true

        // Prepare the payload
        let outgoingMessages = messages.map { message -> [String: Any] in
            var dict: [String: Any] = [
                "role": message.role.rawValue
            ]
            if let msg = message.message {
                dict["message"] = msg
            }
            if let img = message.image,
               let base64 = img.resized(toHeight: 1000)?.jpegData(compressionQuality: 0.4)?.base64EncodedString() {
                dict["image"] = base64
            }
            return dict
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["messages": outgoingMessages]) else {
            print("Failed to encode JSON.")
            self.isSending = false
            return
        }

        var request = URLRequest(url: URL(string: location)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSending = false

                if let error = error {
                    print("Request error: \(error)")
                    return
                }

                guard let data = data, let reply = String(data: data, encoding: .utf8) else {
                    print("Failed to decode response.")
                    return
                }

                self.appendMessage(role: .system, message: reply)
            }
        }.resume()
    }

    
    func appendMessage(role: MessageRole, message: String? = nil, image: UIImage? = nil) {
        self.date = Date()
        messages.append(ChatMessage(
            role: role,
            message: message,
            image: image
        ))
    }
    
}

enum MessageRole: String, Codable {
    case user
    case system
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    var message: String?
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case message
        case image
    }

    init(id: UUID = UUID(), role: MessageRole, message: String?, image: UIImage? = nil) {
        self.id = id
        self.role = role
        self.message = message
        self.image = image //?.jpegData(compressionQuality: 1.0)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        role = try container.decode(MessageRole.self, forKey: .role)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        /*if let imageData = try container.decodeIfPresent(Data.self, forKey: .image) ?? nil {
            image = UIImage(data: imageData)
        }*/
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(role, forKey: .role)
        try container.encode(message, forKey: .message)
        //try container.encode(image?.jpegData(compressionQuality: 1.0), forKey: .image)
        
        if let image = self.image,
           let resizedImage = self.resizedImage(image),
           let resizedImageData = resizedImage.jpegData(compressionQuality: 0.4) {
            let base64String = resizedImageData.base64EncodedString()
            try container.encode(base64String, forKey: .image)
        }

        
    }

    private func resizedImage(_ image: UIImage) -> UIImage? {
        //increase size of image here:
        if image.size.height > 1000 {
            return image.resized(toHeight: 1000)
        }
        else {
            return image
        }
    }
    
    
    private func encodeToPercentEncodedString(_ data: Data) -> String {
        return data.map { String(format: "%%%02hhX", $0) }.joined()
    }

    


}
