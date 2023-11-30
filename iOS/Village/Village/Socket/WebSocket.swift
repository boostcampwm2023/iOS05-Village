//
//  WebSocket.swift
//  Village
//
//  Created by 박동재 on 2023/11/29.
//

import Foundation

final class WebSocket: NSObject {
    static let shared = WebSocket()
    
    var url: URL?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    
    private override init() {}
    
    func openWebSocket() throws {
        guard let url = url else { throw WebSocketError.invalidURL }

        let urlSession = URLSession.shared
        let webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        
        self.webSocketTask = webSocketTask
        
        self.startPing()
        
        self.receiveEvent()
    }
    
    func sendJoinRoom(roomID: String) {
        let joinRoomEvent = """
        {
          "event": "join-room",
          "data": {
            "room": "\(roomID)"
          }
        }
        """
        guard let jsonData = joinRoomEvent.data(using: .utf8) else { return }
        send(data: jsonData)
    }
    
    func sendMessage(roomID: String, sender: String, message: String) {
        let sendMessageEvent = """
        {
          "event": "send-message",
          "data": {
            "room": "\(roomID)",
            "message": "\(message)",
            "sender": "\(sender)"
          }
        }
        """
        guard let jsonData = sendMessageEvent.data(using: .utf8) else { return }
        send(data: jsonData)
    }
    
    func sendDisconnectRoom(roomID: String) {
        let disconnectRoomEvent = """
        {
          "event": "leave-room",
          "data": {
            "room": "\(roomID)"
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
        print("receiveEvent")
        
        guard let webSocketTask = self.webSocketTask else {
            print("WebSocketTask is nil")
            return
        }
        
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    print("Received message: \(text)")
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
