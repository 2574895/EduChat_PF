import SwiftUI
// import MarkdownUI // 패키지 문제 해결 후 활성화

struct MessageBubble: View {
    let message: Message
    @State private var isHovered = false

    // 마크다운 스타일링을 위한 포맷터 (AIResponseFormatter에서 처리됨)
    private var formattedContent: String {
        return message.content
    }

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                if #available(macOS 12.0, *) {
                    Text(.init(message.content))
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
                }
            } else {
                // 임시: 패키지 문제 해결 전까지 Text 사용
                Text(.init(formattedContent))
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
                            NSPasteboard.general.setString(formattedContent, forType: .string)
                        }) {
                            Text("복사")
                            Image(systemName: "doc.on.doc")
                        }
                        Button(action: {
                            #if os(macOS)
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(formattedContent, forType: .string)
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
