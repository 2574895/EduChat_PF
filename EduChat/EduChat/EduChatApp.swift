import SwiftUI

@main
struct EduChatApp: App {
    @StateObject private var chatManager = ChatManager()

    var body: some Scene {
        WindowGroup("EduChat") {
            ChatView(chatManager: chatManager)
        }
    }
}
