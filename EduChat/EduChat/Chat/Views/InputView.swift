import SwiftUI

struct InputView: View {
    @ObservedObject var chatManager: ChatManager
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Toggle("📚 딥러닝 모드", isOn: $chatManager.fullStudyMode)
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(chatManager.isWaitingForPreliminaryQuestions) // 사전 질문 중에는 비활성화
                if chatManager.fullStudyMode {
                    Text("AI가 아주 자세하게 설명해드립니다")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.leading, 4)
                }
                Spacer()
                // 새 채팅 아이콘
                Button(action: { chatManager.createNewSession() }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(chatManager.isWaitingForPreliminaryQuestions) // 사전 질문 중에는 비활성화
                // 대화 목록 아이콘
                Button(action: { chatManager.showChatHistory = true }) {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(chatManager.isWaitingForPreliminaryQuestions) // 사전 질문 중에는 비활성화
                // 설정 아이콘
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(chatManager.isWaitingForPreliminaryQuestions) // 사전 질문 중에는 비활성화
            }


            HStack(spacing: 6) {
                TextField(
                    chatManager.isWaitingForPreliminaryQuestions
                        ? "사전 질문에 답변해주세요..."
                        : "메시지를 입력하세요...",
                    text: $messageText,
                    axis: .vertical
                )
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .lineLimit(1...3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .lineLimit(1...3)
                    .focused($isTextFieldFocused)
                    .onSubmit { sendMessage() }
                    .disabled(chatManager.isLoading) // 로딩 중에만 입력 불가

                Button(action: sendMessage) {
                    Image(systemName: chatManager.isLoading ? "circle.dotted" : "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(
                            (messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatManager.isLoading || chatManager.isWaitingForPreliminaryQuestions)
                            ? Color.gray
                            : Color.blue
                        )
                        .clipShape(Circle())
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatManager.isLoading || chatManager.isWaitingForPreliminaryQuestions)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.05))
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isTextFieldFocused = true } }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $chatManager.showChatHistory) {
            ChatHistoryView(chatManager: chatManager)
        }
    }

    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard !chatManager.isLoading else { return }
        chatManager.send(trimmedText)
        messageText = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isTextFieldFocused = true }
    }
}
