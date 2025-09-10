import SwiftUI
// import MarkdownUI // Swift Package Manager에서 추가 필요

struct MessageBubble: View {
    let message: Message
    @State private var isHovered = false

    // MarkdownUI 사용 시
    private var markdownContent: String {
        // AIResponseFormatter에서 변환된 마크다운 콘텐츠 사용
        return message.content
    }

    // 기존 방식 (fallback)
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
                // MarkdownUI 사용 (라이브러리가 추가되면 활성화)
                /*
                if #available(macOS 12.0, *) {
                    Markdown(markdownContent)
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
                                NSPasteboard.general.setString(markdownContent, forType: .string)
                            }) {
                                Text("복사")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                } else {
                    // MarkdownUI를 사용할 수 없는 경우 기존 방식으로 fallback
                }
                */

                // 현재 방식 (MarkdownUI 추가 전까지 사용)
                if #available(macOS 12.0, *) {
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
                } else {
                    Text(formattedContent)
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
