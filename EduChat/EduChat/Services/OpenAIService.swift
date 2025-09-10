import Foundation

class OpenAIService {
    private let defaultModel = "gpt-5-nano"

    enum OpenAIError: Error {
        case missingAPIKey
        case emptyResponse
        case networkError(Error)
        case invalidResponse
    }

    func generateReply(prompt: String, isStudyMode: Bool = false) async throws -> String {
        let apiKey = getAPIKey()
        guard !apiKey.isEmpty && apiKey.hasPrefix("sk-") else { throw OpenAIError.missingAPIKey }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        // 딥러닝 모드에서는 긴 응답을 위해 타임아웃을 늘림 (5분)
        request.timeoutInterval = isStudyMode ? 300 : 60
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let messages: [[String: String]]
        if isStudyMode {
            messages = [
                ["role": "system", "content": """
                당신은 EduAI입니다. AI와 데이터 과학 분야의 전략적 교육 전문가로서 심층적이고 구조화된 설명을 제공합니다.

                다음 6가지 섹션으로 나누어 심층적으로 설명해주세요:

                1. 개념의 핵심 본질 파악 - 적절한 비유를 사용하여 개념의 본질을 직관적으로 설명
                2. 표면과 관계성 분석 - 기초 개념 이해와 관련 개념과의 관계
                3. 원리와 구현 방법 - 이론적 기반과 실제 적용 기술
                4. 응용과 활용 분야 - 다양한 분야에서의 실질적 활용
                5. 역사적 발전과 맥락 - 발전 과정과 진화, 역사적 의미
                6. 한계와 미래 전망 - 제약사항 분석과 발전 방향

                규칙:
                - 각 섹션 사이에 빈 줄로 구분
                - 텍스트를 문단으로 나누어 작성
                - 코드 예시와 실습 과제 절대 금지
                - 존댓말 사용
                """],
                ["role": "user", "content": prompt]
            ]
        } else {
            messages = [
                ["role": "system", "content": """
                당신은 EduAI입니다. AI와 데이터 과학 분야의 실용적 교육 전문가입니다.

                다음 두 가지 섹션으로 나누어 설명해주세요:

                1. 비유를 통한 핵심 요약 - 비유를 사용하여 개념을 쉽게 설명
                2. 개념의 역사 - 이 개념의 간단한 발전 역사

                규칙:
                - 응답 길이: 100~200단어
                - 존댓말 사용
                - 코드 예시 금지
                - 각 섹션 사이 빈 줄로 구분
                - 가벼운 인사는 간단히 응답
                """],
                ["role": "user", "content": prompt]
            ]
        }

        let body = [
            "model": defaultModel,
            "messages": messages,
        ] as [String : Any]

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw OpenAIError.invalidResponse }

        let decoded = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else { throw OpenAIError.emptyResponse }
        return content
    }

    private func getAPIKey() -> String {
        return UserDefaults.standard.string(forKey: Constants.userDefaultsKeys.apiKey) ?? ""
    }
}

// Minimal response models
struct OpenAIChatResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable { let message: Message }
    struct Message: Codable { let content: String }
}
