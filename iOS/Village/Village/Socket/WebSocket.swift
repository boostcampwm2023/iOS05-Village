//
//  WebSocket.swift
//  Village
//
//  Created by 박동재 on 2023/11/29.
//

import Foundation
import Combine

class MessageManager {
    static let shared = MessageManager()
    let messageSubject = PassthroughSubject<ReceiveMessage, Never>()
    
    private init() {}
}

struct ReceiveMessage: Hashable, Codable {
    
    let sender: String
    let message: String
    let isRead: Bool
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case sender
        case message
        case isRead = "is_read"
        case count
    }
    
}
final class WebSocket: NSObject {
    static let shared = WebSocket()
    
    var url: URL?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    
    private override init() {}
    
    func openWebSocket() throws {
        let configuration = URLSessionConfiguration.default
        guard let accessToken = JWTManager.shared.get()?.accessToken else { return }
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)"]
        
        guard let url = url else { throw WebSocketError.invalidURL }

        let urlSession = URLSession(configuration: configuration)
        let webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        
        self.webSocketTask = webSocketTask
        
        self.startPing()
        
        self.receiveEvent()
    }
    
    func sendJoinRoom(roomID: Int) {
        let joinRoomEvent = """
        {
          "event": "join-room",
          "data": {
            "room_id": \(roomID)
          }
        }
        """
        guard let jsonData = joinRoomEvent.data(using: .utf8) else { return }
        send(data: jsonData)
    }
    
    func sendMessage(roomID: Int, sender: String, message: String, count: Int) {
        let sendMessageEvent = """
        {
          "event": "send-message",
          "data": {
            "room_id": \(roomID),
            "message": "\(message)",
            "sender": "\(sender)",
            "count": \(count)
          }
        }
        """
        guard let jsonData = sendMessageEvent.data(using: .utf8) else { return }
        send(data: jsonData)
    }
    
    func sendDisconnectRoom(roomID: Int) {
        let disconnectRoomEvent = """
        {
          "event": "leave-room",
          "data": {
            "room_id": \(roomID)
          }
        }
        """
        guard let jsonData = disconnectRoomEvent.data(using: .utf8) else { return }
        send(data: jsonData)
    }
    
    private func send(data: Data) {
        self.webSocketTask?.send(.data(data)) { error in
            if let error = error {
                print("오류 발생: \(error)")
            } else {
                print("메시지 전송 완료")
            }
        }
    }
    
    func receiveEvent() {
        guard let webSocketTask = self.webSocketTask else {
            return
        }
        
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    if let jsonData = text.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let message = try decoder.decode(ReceiveMessage.self, from: jsonData)
                            MessageManager.shared.messageSubject.send(message)
                        } catch {
                            dump(error)
                        }
                    }
                }
                self.receiveEvent()
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
        }
    }
    
    private func startPing() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
            withTimeInterval: 10,
            repeats: true,
            block: { [weak self] _ in self?.ping() }
        )
    }
    
    private func ping() {
        self.webSocketTask?.sendPing(pongReceiveHandler: { [weak self] error in
            guard error != nil else { return }
            self?.startPing()
        })
    }
}
