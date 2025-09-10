import SwiftUI

struct ChatHistoryView: View {
    @ObservedObject var chatManager: ChatManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // macOS용 상단 바
            HStack {
                Text("대화 기록")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("닫기") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))

            // 메인 컨텐츠
            if chatManager.sessions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "message")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("아직 채팅 기록이 없습니다")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("새로운 대화를 시작해보세요!")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(chatManager.sessions) { session in
                        ChatHistoryRow(session: session,
                                     isSelected: session.id == chatManager.currentSessionId)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            chatManager.switchToSession(session.id)
                            dismiss()
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                chatManager.deleteSession(session.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.inset)
                .frame(minWidth: 400, minHeight: 300)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct ChatHistoryRow: View {
    let session: ChatSession
    let isSelected: Bool

    private var displayTitle: String {
        if session.title.isEmpty {
            return session.hasStarted ? "새로운 대화" : "시작되지 않은 대화"
        }
        return session.title
    }

    private var displayDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")

        if Calendar.current.isDateInToday(session.createdAt) {
            formatter.dateFormat = "HH:mm"
            return "오늘 \(formatter.string(from: session.createdAt))"
        } else if Calendar.current.isDateInYesterday(session.createdAt) {
            formatter.dateFormat = "HH:mm"
            return "어제 \(formatter.string(from: session.createdAt))"
        } else {
            formatter.dateFormat = "M월 d일 HH:mm"
            return formatter.string(from: session.createdAt)
        }
    }

    private var messageCount: Int {
        session.messages.filter { $0.isFromUser }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(displayTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
            }

            HStack(spacing: 8) {
                Text(displayDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                if messageCount > 0 {
                    Text("•")
                        .foregroundColor(.gray)

                    Text("\(messageCount)개의 질문")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

struct ChatHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let chatManager = ChatManager()
        // 샘플 데이터 추가
        let sampleSession = ChatSession()
        chatManager.sessions = [sampleSession]
        chatManager.currentSessionId = sampleSession.id

        return ChatHistoryView(chatManager: chatManager)
    }
}
