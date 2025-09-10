import SwiftUI
import MarkdownUI

struct MessageBubble: View {
    let message: Message

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
                        .font(.system(size: 17))
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .frame(maxWidth: 360, alignment: .trailing)
                        .textSelection(.enabled)
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
                        .font(.system(size: 17))
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .frame(maxWidth: 360, alignment: .trailing)
                        .textSelection(.enabled)
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
                // 로컬 패키지 사용 - 풍부한 마크다운 렌더링
                if #available(macOS 12.0, *) {
                    Markdown(formattedContent)
                        .markdownTheme(.gitHub)
                        .font(.system(size: 17))
                        .padding(14)
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
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
                    // macOS 12.0 미만에서는 Text 사용 (하위 호환성)
                    Text(.init(formattedContent))
                        .font(.system(size: 17))
                        .padding(14)
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
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
