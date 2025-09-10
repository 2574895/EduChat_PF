import SwiftUI

struct MessageBubble: View {
    let message: Message
    @State private var isHovered = false

    // AI 응답을 마크다운 형식으로 변환
    private var formattedContent: String {
        guard !message.isFromUser else { return message.content }

        // 딥러닝 모드 응답 포맷팅 - 강력한 패턴 매칭
        var formatted = message.content
        var hasChanges = false

        // 1. 개념의 핵심 본질 파악 (유연한 매칭)
        if formatted.contains("개념의 핵심 본질 파악") {
            formatted = formatted.replacingOccurrences(of: "개념의 핵심 본질 파악", with: "**1. 🧠 개념의 핵심 본질 파악**\n")
            hasChanges = true
        }

        // 2. 표면과 관계성 분석 (유연한 매칭)
        if formatted.contains("표면과 관계성 분석") {
            formatted = formatted.replacingOccurrences(of: "표면과 관계성 분석", with: "\n\n**2. 🔍 표면과 관계성 분석**\n")
            hasChanges = true
        }

        // 3. 원리와 구현 방법 (유연한 매칭)
        if formatted.contains("원리와 구현 방법") {
            formatted = formatted.replacingOccurrences(of: "원리와 구현 방법", with: "\n\n**3. ⚙️ 원리와 구현 방법**\n")
            hasChanges = true
        }

        // 4. 응용과 활용 분야 (유연한 매칭)
        if formatted.contains("응용과 활용 분야") {
            formatted = formatted.replacingOccurrences(of: "응용과 활용 분야", with: "\n\n**4. 🌐 응용과 활용 분야**\n")
            hasChanges = true
        }

        // 5. 역사적 발전과 맥락 (유연한 매칭)
        if formatted.contains("역사적 발전과 맥락") {
            formatted = formatted.replacingOccurrences(of: "역사적 발전과 맥락", with: "\n\n**5. 📚 역사적 발전과 맥락**\n")
            hasChanges = true
        }

        // 6. 한계와 미래 전망 (유연한 매칭)
        if formatted.contains("한계와 미래 전망") {
            formatted = formatted.replacingOccurrences(of: "한계와 미래 전망", with: "\n\n**6. ⚖️ 한계와 미래 전망**\n")
            hasChanges = true
        }

        // 변경사항이 있으면 변환된 내용 반환
        if hasChanges {
            return formatted
        }

        // 일반 모드 응답 포맷팅 - 강력하고 간단한 변환
        var formattedNormal = message.content
        var hasNormalChanges = false

        // 1. "비유를 통한 핵심 요약" 섹션 변환
        if formattedNormal.contains("비유를 통한 핵심 요약") {
            formattedNormal = formattedNormal.replacingOccurrences(of: "비유를 통한 핵심 요약", with: "\n**📌 비유를 통한 핵심 요약**\n")
            hasNormalChanges = true
        }

        // 2. "개념의 역사" 섹션 변환
        if formattedNormal.contains("개념의 역사") {
            formattedNormal = formattedNormal.replacingOccurrences(of: "개념의 역사", with: "\n\n**📚 개념의 역사**\n")
            hasNormalChanges = true
        }

        // 변환된 내용이 있으면 반환
        if hasNormalChanges {
            return formattedNormal
        }

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
