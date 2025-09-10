import SwiftUI

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
                // 간단한 텍스트 렌더링으로 변경 (마크다운 대신)
                Text(message.content)
                    .font(.system(size: 17))
                    .padding(14)
                    .background(Color.secondary.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .lineSpacing(4) // 적절한 줄 간격 추가
                    .contextMenu {
                        Button(action: {
                            copyToClipboard(message.content)
                        }) {
                            Text("복사")
                            Image(systemName: "doc.on.doc")
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
