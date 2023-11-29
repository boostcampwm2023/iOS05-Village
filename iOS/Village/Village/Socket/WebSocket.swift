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
    var onReceiveClosure: ((String?, Data?) -> Void)?
    weak var delegate: URLSessionWebSocketDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask? {
        didSet { oldValue?.cancel(with: .goingAway, reason: nil) }
    }
    private var timer: Timer?
    
    private override init() {}
    
    func openWebSocket() throws {
        guard let url = url else { throw WebSocketError.invalidURL }
        print("openWebSocket")
        
        let urlSession = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        let webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        
        self.webSocketTask = webSocketTask
        
        self.startPing()
    }
    
    func send(message: String) {
        self.send(message: message, data: nil)
    }
    
    func send(data: Data) {
        self.send(message: nil, data: data)
    }
    
    private func send(message: String?, data: Data?) {
        let taskMessage: URLSessionWebSocketTask.Message
        if let string = message {
            taskMessage = URLSessionWebSocketTask.Message.string(string)
        } else if let data = data {
            taskMessage = URLSessionWebSocketTask.Message.data(data)
        } else {
            return
        }
        
        print("Send message \(taskMessage)")
        self.webSocketTask?.send(taskMessage, completionHandler: { error in
            guard let error = error else { return }
        })
    }
    
    func closeWebSocket() {
        print("closeWebSocket")
        self.webSocketTask?.cancel(with: .normalClosure, reason: nil)
        self.timer?.invalidate()
        self.onReceiveClosure = nil
        self.delegate = nil
    }
    
    func receive(onReceive: @escaping (String?, Data?) -> Void) {
        self.onReceiveClosure = onReceive
        self.webSocketTask?.receive(completionHandler: { result in
            switch result {
            case let .success(message):
                switch message {
                case let .string(string):
                    onReceive(string, nil)
                case let .data(data):
                    onReceive(nil, data)
                @unknown default:
                    onReceive(nil, nil)
                }
            case let .failure(error):
                print("Received error \(error)")
            }
        })
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
            guard let error = error else { return }
            self?.startPing()
        })
    }
}

extension WebSocket: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        self.delegate?.urlSession?(
            session,
            webSocketTask: webSocketTask,
            didOpenWithProtocol: `protocol`
        )
    }
    
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        self.delegate?.urlSession?(
            session,
            webSocketTask: webSocketTask,
            didCloseWith: closeCode,
            reason: reason
        )
    }
}
