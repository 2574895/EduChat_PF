import SwiftUI

struct MessageBubble: View {
    let message: Message
    @State private var isHovered = false

    // AI 응답을 마크다운 형식으로 변환
    private var formattedContent: String {
        guard !message.isFromUser else { return message.content }

        // 딥러닝 모드 응답 포맷팅
        if message.content.contains("1. 개념의 핵심 본질 파악") ||
           message.content.contains("2. 표면과 관계성 분석") ||
           message.content.contains("3. 원리와 구현 방법") ||
           message.content.contains("4. 응용과 활용 분야") ||
           message.content.contains("5. 역사적 발전과 맥락") ||
           message.content.contains("6. 한계와 미래 전망") {

            return message.content
                .replacingOccurrences(of: "1. 개념의 핵심 본질 파악", with: "**1. 🧠 개념의 핵심 본질 파악**")
                .replacingOccurrences(of: "2. 표면과 관계성 분석", with: "**2. 🔍 표면과 관계성 분석**")
                .replacingOccurrences(of: "3. 원리와 구현 방법", with: "**3. ⚙️ 원리와 구현 방법**")
                .replacingOccurrences(of: "4. 응용과 활용 분야", with: "**4. 🌐 응용과 활용 분야**")
                .replacingOccurrences(of: "5. 역사적 발전과 맥락", with: "**5. 📚 역사적 발전과 맥락**")
                .replacingOccurrences(of: "6. 한계와 미래 전망", with: "**6. ⚖️ 한계와 미래 전망**")
        }

        // 일반 모드 응답 포맷팅
        if message.content.contains("1. 비유를 통한 핵심 요약") ||
           message.content.contains("2. 개념의 역사") {

            return message.content
                .replacingOccurrences(of: "1. 비유를 통한 핵심 요약", with: "**📌 비유를 통한 핵심 요약**")
                .replacingOccurrences(of: "2. 개념의 역사", with: "**📚 개념의 역사**")
        }

        return message.content
    }

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                if #available(macOS 12.0, *) {
                    Text(.init(message.content))
                } else {
                    Text(message.content)
                }
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
                if #available(macOS 12.0, *) {
                    Text(.init(formattedContent))
                } else {
                    Text(formattedContent)
                }
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
