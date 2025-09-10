import SwiftUI

struct MessageBubble: View {
    let message: Message
    @State private var isHovered = false

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Text(message.content)
                    .font(.system(size: 16))
                    .padding(12)
                    .background(Color.blue.opacity(isHovered ? 0.8 : 1.0))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .frame(maxWidth: 360, alignment: .trailing)
                    .textSelection(.enabled)
                    .onHover { hovering in
                        isHovered = hovering
                    }
                    .contextMenu {
                        Button(action: {
                            copyToClipboard(message.content)
                        }) {
                            Text("복사")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            } else {
                Text(message.content)
                    .padding(14)
                    .background(Color.secondary.opacity(isHovered ? 0.4 : 0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .onHover { hovering in
                        isHovered = hovering
                    }
                    .contextMenu {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(message.content, forType: .string)
                        }) {
                            Text("복사")
                            Image(systemName: "doc.on.doc")
                        }
                        Button(action: {
                            #if os(macOS)
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(message.content, forType: .string)
                            #endif
                        }) {
                            Text("전체 선택 후 복사")
                            Image(systemName: "checkmark.circle")
                        }
                    }
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}
