import SwiftUI

@main
struct EduChatApp: App {
    @StateObject private var chatManager = ChatManager()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup("EduChat") {
            ChatView(chatManager: chatManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
