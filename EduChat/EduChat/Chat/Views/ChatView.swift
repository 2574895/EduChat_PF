import SwiftUI

struct ChatView: View {
    @ObservedObject var chatManager: ChatManager

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    // Ensure content is anchored to the top by using a top-aligned VStack inside LazyVStack
                    LazyVStack(alignment: .leading, spacing: 12) {
                        // Anchor top: zero-height spacer ensures content starts at top
                        Color.clear.frame(height: 0)
                        
                        ForEach(chatManager.messages, id: \.id) { message in
                            if isWelcomeMessage(message) {
                                WelcomeMessageView(message: message)
                            } else if message.isFromUser {
                                // 사용자 메시지: 기존처럼 버블 형태
                                MessageBubble(message: message)
                            } else {
                                // AI 메시지: ChatGPT 스타일로 일반 텍스트 표시
                                AIMessageView(message: message)
                            }
                        }
                        if chatManager.isLoading {
                            HStack {
                                ProgressView().scaleEffect(0.8)
                                Text(chatManager.isWaitingForPreliminaryQuestions ? "💭 사용자 응답을 기다리는 중..." : "🤔 생각중...")
                                    .font(.system(size: 14))
                                    .foregroundColor(chatManager.isWaitingForPreliminaryQuestions ? .orange : .blue)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background((chatManager.isWaitingForPreliminaryQuestions ? Color.orange : Color.blue).opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .id("loading") // 고유 ID 부여
                        }
                    }
                    .frame(maxWidth: .infinity)
                    // Ensure the content expands to top; allow flexible height
                    .padding(.top, 8)
                }
                .background(Color.clear)
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 80)
                .onChange(of: chatManager.messages.count) { newCount in
                    // 새로운 메시지가 추가되었을 때만 스크롤
                    if newCount > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let lastMessage = chatManager.messages.last {
                                // Scroll so that the last message is visible at the bottom
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }

            if let errorMessage = chatManager.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                    Text(errorMessage).font(.caption).foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }

            InputView(chatManager: chatManager)
                .background(Color.gray.opacity(0.05))
        }
        .id(chatManager.currentSessionId)
    }

    private func isWelcomeMessage(_ message: Message) -> Bool {
        return !message.isFromUser && message.content.contains("EduChat에 오신 것을 환영합니다")
    }
}

struct WelcomeMessageView: View {
    let message: Message

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Text(message.content)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .frame(maxWidth: 600) // 최대 너비 제한으로 가독성 향상
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.secondary.opacity(0.3))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 40) // 화면 상단에 위치 (복구)
        }
        .id(message.id)
    }
}

struct AIMessageView: View {
    let message: Message

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // AI 응답 텍스트 - 마크다운 지원으로 굵은체 텍스트 강조
            if #available(iOS 15.0, macOS 12.0, *) {
                if let attributedString = try? AttributedString(markdown: formatMarkdownText(message.content)) {
                    Text(attributedString)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .lineLimit(nil) // 긴 텍스트 제한 제거 - 3000~4000단어 응답 지원
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                        .layoutPriority(1) // 긴 텍스트가 우선적으로 표시되도록 함
                        .contextMenu {
                            Button(action: {
                                copyToClipboard(message.content)
                            }) {
                                Text("복사")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                } else {
                    // 마크다운 파싱 실패 시 일반 텍스트로 표시
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .lineLimit(nil) // 긴 텍스트 제한 제거 - 3000~4000단어 응답 지원
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                        .layoutPriority(1) // 긴 텍스트가 우선적으로 표시되도록 함
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
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .lineLimit(nil) // 긴 텍스트 제한 제거 - 3000~4000단어 응답 지원
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                    .layoutPriority(1) // 긴 텍스트가 우선적으로 표시되도록 함
                    .contextMenu {
                        Button(action: {
                            copyToClipboard(message.content)
                        }) {
                            Text("복사")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }
        }
        .id(message.id)
    }

    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }

    private func formatMarkdownText(_ text: String) -> String {
        var formattedText = text

        // 1. 메인 섹션 굵은체 강조 및 구조화 (프롬프트에서 지정한 정확한 형식)
        // 빈 줄 3줄을 강제로 적용하여 섹션 구분 명확화
        formattedText = formattedText.replacingOccurrences(of: "1. 🧠 개념의 핵심 본질 파악", with: "\n\n\n**1. 🧠 개념의 핵심 본질 파악**\n")
        formattedText = formattedText.replacingOccurrences(of: "2. 🔬 층위별 심층 분석", with: "\n\n\n**2. 🔬 층위별 심층 분석**\n")
        formattedText = formattedText.replacingOccurrences(of: "3. 📚 역사적 발전 과정", with: "\n\n\n**3. 📚 역사적 발전 과정**\n")
        formattedText = formattedText.replacingOccurrences(of: "4. 🔮 미래 전망과 방향성", with: "\n\n\n**4. 🔮 미래 전망과 방향성**\n")
        formattedText = formattedText.replacingOccurrences(of: "5. ⚖️ 한계·비교·평가", with: "\n\n\n**5. ⚖️ 한계·비교·평가**\n")
        formattedText = formattedText.replacingOccurrences(of: "6. 🚀 마무리 및 다음 단계", with: "\n\n\n**6. 🚀 마무리 및 다음 단계**\n")

        // 2. 서브 섹션 굵은체 강조
        formattedText = formattedText.replacingOccurrences(of: "2.1 표면:", with: "**2.1 표면:**")
        formattedText = formattedText.replacingOccurrences(of: "2.2 원리:", with: "**2.2 원리:**")
        formattedText = formattedText.replacingOccurrences(of: "2.3 구현:", with: "**2.3 구현:**")
        formattedText = formattedText.replacingOccurrences(of: "2.4 응용:", with: "**2.4 응용:**")

        // 3. 추가 서브 섹션들
        formattedText = formattedText.replacingOccurrences(of: "3.1 표면 수준 실습:", with: "**3.1 표면 수준 실습:**")
        formattedText = formattedText.replacingOccurrences(of: "3.1. 표면 수준 실습:", with: "**3.1. 표면 수준 실습:**")

        // 3. 일반 모드 섹션 포맷팅 (빈 줄 1줄)
        formattedText = formattedText.replacingOccurrences(of: "📌 핵심 요약", with: "\n📌 핵심 요약\n")
        formattedText = formattedText.replacingOccurrences(of: "⚙️ 권장 실행", with: "\n⚙️ 권장 실행\n")
        formattedText = formattedText.replacingOccurrences(of: "🧪 간단 예시", with: "\n🧪 간단 예시\n")

        // 4. 주요 AI/ML 용어 굵은체 강조
        let keywords = ["머신러닝", "딥러닝", "AI", "인공지능", "신경망", "알고리즘", "데이터", "모델", "학습", "예측"]
        for keyword in keywords {
            formattedText = formattedText.replacingOccurrences(of: keyword, with: "**\(keyword)**")
        }

        // 5. 기존 **텍스트** 형식은 유지하되 중복 방지
        // (이미 굵은체인 텍스트는 다시 처리하지 않음)

        return formattedText
    }
}