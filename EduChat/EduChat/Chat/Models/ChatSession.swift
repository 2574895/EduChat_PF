import Foundation

struct ChatSession: Codable, Identifiable {
    var id = UUID()
    var messages: [Message] = []
    var selectedModel: String = "gpt-5-nano"
    var title: String = ""
    var createdAt: Date = Date()

    mutating func addMessage(_ msg: Message) { messages.append(msg) }

    // 채팅 주제 생성 (첫 번째 사용자 메시지 기반)
    mutating func updateTitleFromFirstMessage() {
        guard let firstUserMessage = messages.first(where: { $0.isFromUser }) else { return }

        let content = firstUserMessage.content
        if content.count <= 30 {
            title = content
        } else {
            // 30자 이상이면 앞부분만 사용하고 ... 추가
            let endIndex = content.index(content.startIndex, offsetBy: 27)
            title = String(content[..<endIndex]) + "..."
        }
    }

    // 채팅이 시작되었는지 확인
    var hasStarted: Bool {
        return messages.contains(where: { $0.isFromUser })
    }
}
