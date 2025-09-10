import Foundation
import SwiftUI

@MainActor
final class ChatManager: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var currentSessionId: UUID?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var fullStudyMode = false {
        didSet {
            if fullStudyMode && !oldValue {
                // 딥러닝 모드가 켜졌을 때 새 세션 생성
                createNewSession()
                // 딥러닝 모드 웰컴 메시지 추가
                addDeepLearningWelcomeMessage()
            } else if !fullStudyMode && oldValue {
                // 딥러닝 모드가 꺼졌을 때 일반 모드로 전환
                switchToNormalMode()
            }
        }
    }
    @Published var showChatHistory = false

    // 사전 질문 관련 상태
    @Published var isWaitingForPreliminaryQuestions = false
    @Published var pendingUserQuestion: String?
    @Published var preliminaryQuestionStep = 0 // 0: 주제, 1: 기초 여부

    private let openAIService = OpenAIService()
    private let sessionsKey = "chat_sessions"

    // LLM 응답 캐싱을 위한 메모리 캐시
    private var responseCache = [String: String]()
    private let maxCacheSize = 20 // 최대 캐시 개수

    // 캐시 키 생성
    private func cacheKey(for prompt: String, isStudyMode: Bool) -> String {
        return "\(isStudyMode ? "study" : "normal")_\(prompt.hashValue)"
    }

    // 캐시에서 응답 가져오기
    private func getCachedResponse(for prompt: String, isStudyMode: Bool) -> String? {
        let key = cacheKey(for: prompt, isStudyMode: isStudyMode)
        return responseCache[key]
    }

    // 캐시에 응답 저장
    private func cacheResponse(_ response: String, for prompt: String, isStudyMode: Bool) {
        let key = cacheKey(for: prompt, isStudyMode: isStudyMode)
        responseCache[key] = response

        // 캐시 크기 제한
        if responseCache.count > maxCacheSize {
            // 가장 오래된 항목 제거 (간단한 구현)
            if let firstKey = responseCache.keys.first {
                responseCache.removeValue(forKey: firstKey)
            }
        }
    }

    var currentSession: ChatSession? {
        guard let sessionId = currentSessionId else { return nil }
        return sessions.first(where: { $0.id == sessionId })
    }

    var messages: [Message] {
        return currentSession?.messages ?? []
    }

    init() {
        // 앱 실행 시 채팅 기록은 유지하되 새로운 세션으로 시작
        loadSessions() // 기존 채팅 기록 로드 (채팅 기록용)
        createNewSession() // 새로운 세션 생성 (현재 사용용)
    }

    // 기존 웰컴 메시지 초기화 코드 제거됨 - 이제 각 세션에서 관리

    // 세션들을 UserDefaults에서 불러오기
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey) {
            do {
                sessions = try JSONDecoder().decode([ChatSession].self, from: data)
                // 기존 세션들에 웰컴 메시지가 없는 경우 추가
                for i in 0..<sessions.count {
                    if sessions[i].messages.isEmpty {
                        let welcomeMessage = Message(
                            content: """
                            🤖 **EduChat에 오신 것을 환영합니다!**

                            저는 AI와 데이터 과학 분야의 전문가로서, 여러분의 학습을 도와드립니다.

                            **💡 사용 방법:**
                            • 일반 모드: 빠르고 간단한 답변 
                            • 📚 딥러닝 모드: 심층적이고 체계적인 교육 

                            **⚙️ 설정하기:**
                            먼저 우측 상단의 ⚙️ 버튼을 눌러 OpenAI API 키를 설정해주세요.

                            **🚀 시작하기:**
                            "인공신경망이 뭐야?" 또는 "머신러닝 알고리즘 종류를 알려줘" 같은 질문을 해보세요!

                            AI와 데이터 과학에 대한 모든 궁금증을 해결해드리겠습니다! 🎓✨
                            """,
                            isFromUser: false
                        )
                        sessions[i].addMessage(welcomeMessage)
                    }
                }
            } catch {
                print("세션 로드 실패: \(error)")
                sessions = []
            }
        }
    }

    // 세션들을 UserDefaults에 저장하기
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
        } catch {
            print("세션 저장 실패: \(error)")
        }
    }

    // 새로운 채팅 세션 생성
    func createNewSession() {
        var newSession = ChatSession()

        // 웰컴 메시지 추가 (딥러닝 모드에서는 웰컴 메시지 없음)
        if !fullStudyMode {
            let welcomeMessage = Message(
                content: """
                🤖 **EduChat에 오신 것을 환영합니다!**

                저는 AI와 데이터 과학 분야의 전문가로서, 여러분의 학습을 도와드립니다.

                **💡 사용 방법:**
                • 일반 모드: 빠르고 간단한 답변
                • 📚 딥러닝 모드: 심층적이고 체계적인 교육

                **⚙️ 설정하기:**
                먼저 우측 상단의 ⚙️ 버튼을 눌러 OpenAI API 키를 설정해주세요.

                **🚀 시작하기:**
                "인공신경망이 뭐야?" 또는 "머신러닝 알고리즘 종류를 알려줘" 같은 질문을 해보세요!

                AI와 데이터 과학에 대한 모든 궁금증을 해결해드리겠습니다! 🎓✨
                """,
                isFromUser: false
            )
            newSession.addMessage(welcomeMessage)
        }

        sessions.insert(newSession, at: 0) // 최신 세션을 맨 앞에
        currentSessionId = newSession.id
        saveSessions()
    }

    // 세션 전환
    func switchToSession(_ sessionId: UUID) {
        currentSessionId = sessionId
    }

    // 현재 세션 삭제
    func deleteSession(_ sessionId: UUID) {
        sessions.removeAll(where: { $0.id == sessionId })
        if currentSessionId == sessionId {
            if let firstSession = sessions.first {
                currentSessionId = firstSession.id
            } else {
                createNewSession()
            }
        }
        saveSessions()
    }

    func send(_ text: String) {
        guard var session = currentSession else { return }

        // API 키 확인
        let apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        guard !apiKey.isEmpty else {
            errorMessage = "API 키가 설정되지 않았습니다. 설정에서 OpenAI API 키를 입력해주세요."
            return
        }

        // 첫 번째 사용자 메시지를 보낼 때 환영 메시지 제거 (일반 모드에서만)
        if !fullStudyMode && session.messages.count == 1 && !session.messages[0].isFromUser {
            session.messages.removeAll()
        }

        // 사용자가 자신의 이전 질문을 물어보는 경우 처리
        if isQuestionAboutPreviousQuery(text) {
            handlePreviousQueryQuestion(text)
            return
        }

        // 가벼운 인사 처리 (일반 모드에서만)
        if !fullStudyMode && isCasualGreeting(text) {
            handleCasualGreeting(text, session: session)
            return
        }

        // 딥러닝 모드에서 사전 질문 플로우 처리
        if fullStudyMode {
            if isWaitingForPreliminaryQuestions {
                // 사전 질문에 답변하는 경우
                let userResponse = Message(content: text, isFromUser: true)
                session.addMessage(userResponse)

                // 세션 업데이트
                if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                    sessions[index] = session
                    saveSessions()
                }

                processPreliminaryQuestionResponse(text, session: &session)
            } else {
                // 첫 번째 실제 질문인 경우 사전 질문 시작
                startPreliminaryQuestions(text, session: &session)
            }
            return
        }

        // 일반 모드에서는 바로 AI 응답 요청
        processNormalMode(text, session: session)
    }

    private func handlePreliminaryQuestionsFlow(_ text: String, session: inout ChatSession) {
        if !isWaitingForPreliminaryQuestions {
            // 첫 번째 사전 질문 시작
            startPreliminaryQuestions(text, session: &session)
        } else {
            // 사전 질문에 대한 사용자 응답 처리
            processPreliminaryQuestionResponse(text, session: &session)
        }
    }

    private func startPreliminaryQuestions(_ text: String, session: inout ChatSession) {
        // 사전 질문 상태 설정 (사용자 질문은 이미 채팅창에 추가됨)
        isWaitingForPreliminaryQuestions = true
        preliminaryQuestionStep = 0

        // 첫 번째 사전 질문 메시지 추가
        let questionMessage = Message(content: """
        📚 **딥러닝 모드: 사전 질문**

        1. 이 개념을 어떻게 심층적으로 분석하고 설명할지 계획을 말씀해주세요.
        (예: 단계별로 접근, 특정 측면 위주로, 실무 적용 중심 등)
        """, isFromUser: false)

        session.addMessage(questionMessage)

        // 세션 업데이트
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }

    private func processPreliminaryQuestionResponse(_ text: String, session: inout ChatSession) {
        if preliminaryQuestionStep == 0 {
            // 두 번째 사전 질문 메시지 추가
            let secondQuestionMessage = Message(content: """
            📚 **딥러닝 모드: 사전 질문 (2/2)**

            2. 최종 응답을 어떤 방식으로 구성하고 싶으신가요?
            (예: 구조화된 분석, 실무 중심, 학문적 접근 등)
            """, isFromUser: false)

            session.addMessage(secondQuestionMessage)
            preliminaryQuestionStep = 1

        } else if preliminaryQuestionStep == 1 {
            // 사전 질문 상태 초기화
            isWaitingForPreliminaryQuestions = false
            preliminaryQuestionStep = 0

            // 최종 질문 조합 - 세션에서 사용자의 원래 질문을 찾기
            let userMessages = session.messages.filter { $0.isFromUser }
            let originalQuestion = userMessages.first?.content ?? ""
            let analysisPlan = userMessages.count >= 3 ? userMessages[userMessages.count - 3].content : userMessages.first?.content ?? ""
            let responseStyle = userMessages.last?.content ?? text

            let finalQuestion = """
            사용자가 다음과 같이 질문했습니다:

            [원래 질문]: \(originalQuestion)

            사전 질문 답변:
            [분석 계획]: \(analysisPlan)
            [응답 구성 방식]: \(responseStyle)

            위 내용을 바탕으로 심층적이고 체계적인 설명을 제공해주세요.
            사용자가 제시한 분석 계획("\(analysisPlan)")과 응답 구성 방식("\(responseStyle)")을 고려하여
            개념을 심층적으로 분석하고 설명해주세요.

            시스템 프롬프트에서 지정한 6단계 구조 형식을 정확히 따르세요.
            """

            // AI에게 최종 질문 전송
            processFinalQuestion(finalQuestion, session: session)
        }

        // 세션 업데이트
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }

    private func processNormalMode(_ text: String, session: ChatSession) {
        var session = session

        // 최근 3쌍의 대화만 유지 (사용자 + AI 응답)
        if session.messages.count >= 6 { // 3쌍 = 6개의 메시지
            // 가장 오래된 2개의 메시지 제거 (사용자 질문 + AI 답변 1쌍)
            session.messages.removeFirst(2)
        }

        let user = Message(content: text, isFromUser: true)
        session.addMessage(user)

        // 첫 번째 메시지일 때 제목 업데이트
        if session.messages.filter({ $0.isFromUser }).count == 1 {
            session.updateTitleFromFirstMessage()
        }

        // 세션 업데이트
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }

        Task { @MainActor in
            do {
                isLoading = true
                errorMessage = nil

                var resp: String

                // 1. 캐시에서 응답 확인
                if let cachedResponse = getCachedResponse(for: text, isStudyMode: fullStudyMode) {
                    resp = cachedResponse
                    print("📋 캐시된 LLM 응답 사용: \(resp.prefix(100))...")
                } else {
                    // 2. 캐시에 없으면 API 호출
                    resp = try await openAIService.generateReply(prompt: text, isStudyMode: fullStudyMode)
                    // 3. 응답 캐싱
                    cacheResponse(resp, for: text, isStudyMode: fullStudyMode)
                    print("🤖 새로운 LLM 응답 수신 및 캐싱: \(resp.prefix(100))...")
                }

                let assistant = Message(content: resp, isFromUser: false)

                // 현재 세션에 AI 응답 추가
                guard let currentSessionId = currentSessionId,
                      let sessionIndex = sessions.firstIndex(where: { $0.id == currentSessionId }) else {
                    print("❌ 현재 세션을 찾을 수 없음")
                    isLoading = false
                    return
                }

                // 세션 업데이트 (Published 프로퍼티를 통해 UI 자동 업데이트)
                sessions[sessionIndex].addMessage(assistant)
                saveSessions()

                print("✅ AI 응답 추가 완료 - 메시지 개수: \(sessions[sessionIndex].messages.count)")
                isLoading = false

            } catch {
                print("❌ LLM 호출 에러: \(error)")
                isLoading = false
                if let urlError = error as? URLError, urlError.code == .timedOut {
                    errorMessage = "응답 시간이 너무 오래 걸립니다. 잠시 후 다시 시도해주세요.\n(딥러닝 모드는 긴 응답을 생성하므로 시간이 더 걸릴 수 있습니다)"
                } else {
                    errorMessage = "LLM 호출 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    private func processFinalQuestion(_ finalQuestion: String, session: ChatSession) {
        var session = session

        Task { @MainActor in
            do {
                isLoading = true
                errorMessage = nil

                var resp: String

                // 캐시에서 응답 확인 (딥러닝 모드 최종 질문용)
                if let cachedResponse = getCachedResponse(for: finalQuestion, isStudyMode: true) {
                    resp = cachedResponse
                    print("📋 캐시된 최종 LLM 응답 사용: \(resp.prefix(100))...")
                } else {
                    resp = try await openAIService.generateReply(prompt: finalQuestion, isStudyMode: true)
                    cacheResponse(resp, for: finalQuestion, isStudyMode: true)
                    print("🎯 새로운 최종 LLM 응답 수신 및 캐싱: \(resp.prefix(100))...")
                }

                let assistant = Message(content: resp, isFromUser: false)

                // 현재 세션에 AI 응답 추가
                guard let currentSessionId = currentSessionId,
                      let sessionIndex = sessions.firstIndex(where: { $0.id == currentSessionId }) else {
                    print("❌ 최종 응답 처리 - 현재 세션을 찾을 수 없음")
                    isLoading = false
                    return
                }

                sessions[sessionIndex].addMessage(assistant)
                saveSessions()

                print("✅ 최종 AI 응답 추가 완료 - 메시지 개수: \(sessions[sessionIndex].messages.count)")
                isLoading = false

            } catch {
                print("❌ 최종 LLM 호출 에러: \(error)")
                isLoading = false
                if let urlError = error as? URLError, urlError.code == .timedOut {
                    errorMessage = "응답 시간이 너무 오래 걸립니다. 잠시 후 다시 시도해주세요.\n(딥러닝 모드는 긴 응답을 생성하므로 시간이 더 걸릴 수 있습니다)"
                } else {
                    errorMessage = "LLM 호출 실패: \(error.localizedDescription)"
                }
            }
        }
    }


    private func switchToNormalMode() {
        // 사전 질문 상태 초기화
        resetPreliminaryQuestions()

        // 기존 일반 모드 세션 찾기 (딥러닝 모드 세션이 아닌 것들)
        let normalSessions = sessions.filter { session in
            !session.messages.contains { message in
                message.content.contains("📚 **딥러닝 모드") ||
                message.content.contains("심층적이고 체계적인")
            }
        }

        if let normalSession = normalSessions.first {
            // 기존 일반 모드 세션이 있으면 그것으로 전환
            switchToSession(normalSession.id)
        } else {
            // 일반 모드 세션이 없으면 새로 생성
            createNewSession()
        }
    }

    private func addDeepLearningWelcomeMessage() {
        guard var session = currentSession else { return }

        let welcomeMessage = Message(
            content: "안녕하세요, 자세히 알고싶은 AI/데이터 관련내용이 있으면 말씀해주세요.",
            isFromUser: false
        )
        session.addMessage(welcomeMessage)

        // 세션 업데이트
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }

    private func resetPreliminaryQuestions() {
        isWaitingForPreliminaryQuestions = false
        preliminaryQuestionStep = 0
        pendingUserQuestion = nil
    }

    private func isQuestionAboutPreviousQuery(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return lowercased.contains("내가") &&
               (lowercased.contains("뭘") || lowercased.contains("무엇을")) &&
               (lowercased.contains("물어") || lowercased.contains("질문"))
    }

    private func isCasualGreeting(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // 가벼운 인사 패턴들
        let casualGreetings = [
            "ㅎㅇ", "ㅎㅇㅎㅇ", "ㅎㅇㅎ", "ㅎㅇㅎㅇㅎㅇ",
            "안녕", "안녕하세요", "안뇽", "안뇽하세요",
            "하이", "hi", "hello", "헬로",
            "야", "여", "요",
            "반가워", "반갑습니다"
        ]

        // 정확히 일치하는 경우
        if casualGreetings.contains(trimmedText) {
            return true
        }

        // 4글자 이내의 짧은 인사
        if trimmedText.count <= 4 {
            return casualGreetings.contains { trimmedText.contains($0) }
        }

        return false
    }

    private func handleCasualGreeting(_ text: String, session: ChatSession) {
        var session = session

        let user = Message(content: text, isFromUser: true)
        session.addMessage(user)

        // 상황에 따른 다양한 인사 응답
        let responses = [
            "안녕하세요! AI와 데이터 과학에 대해 궁금한 점이 있으시면 언제든 물어보세요.",
            "반갑습니다! 머신러닝이나 딥러닝 관련 질문이 있으시면 도와드리겠습니다.",
            "안녕하세요! 데이터 과학이나 인공지능 개념에 대해 이야기 나눠보는 건 어떠세요?",
            "반갑습니다! AI 관련 궁금한 점이 있으시면 편하게 질문해주세요."
        ]

        let randomResponse = responses.randomElement() ?? responses[0]
        let assistant = Message(content: randomResponse, isFromUser: false)
        session.addMessage(assistant)

        // 세션 업데이트
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }

    private func handlePreviousQueryQuestion(_ text: String) {
        guard var session = currentSession else { return }

        // 최근 사용자 메시지 찾기
        let recentUserMessages = session.messages.filter { $0.isFromUser }.suffix(2)

        var response: String

        if recentUserMessages.isEmpty {
            response = "죄송하지만 최근에 하신 질문이 없습니다. 새로운 질문을 해주세요!"
        } else if recentUserMessages.count == 1 {
            response = "가장 최근에 하신 질문은:\n\n**\(recentUserMessages[0].content)**\n\n입니다."
        } else {
            response = "최근 하신 질문들은:\n\n1. **\(recentUserMessages[0].content)**\n2. **\(recentUserMessages[1].content)**\n\n입니다."
        }

        let user = Message(content: text, isFromUser: true)
        session.addMessage(user)

        let assistant = Message(content: response, isFromUser: false)
        session.addMessage(assistant)

        // 세션 업데이트
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }
}
