import Foundation

struct ChatUtils {
    // 하드코딩된 모든 주제들
    static let hardcodedTopics = [
        "퍼셉트론",
        "신경망",
        "딥러닝",
        "인공신경망",
        "선형대수학"
    ]

    // 입력 텍스트에서 하드코딩된 주제를 찾는 함수
    static func getHardcodedTopic(for text: String) -> String? {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        for topic in hardcodedTopics {
            if normalizedText.contains(topic.lowercased()) {
                return topic
            }
        }

        return nil
    }

    // 하드코딩된 응답을 가져오는 함수
    static func getHardcodedResponse(for topic: String, isDeepMode: Bool) -> String? {
        if isDeepMode {
            return ChatResponses.deepLearningMode[topic]
        } else {
            return ChatResponses.normalMode[topic]
        }
    }

    // 모든 하드코딩된 주제 목록을 반환하는 함수
    static func getAllHardcodedTopics() -> [String] {
        return hardcodedTopics
    }

    // 주제 선택 질문 메시지를 생성하는 함수
    static func createTopicSelectionQuestion() -> String {
        var question = "🤖 **딥러닝 모드: 주제 선택**\n\n어떤 주제를 심층적으로 분석해볼까요?\n\n"

        for (index, topic) in hardcodedTopics.enumerated() {
            question += "\(index + 1). \(topic)\n"
        }

        question += "\n💡 위 주제 중 하나를 선택하거나, 구체적인 주제를 입력해주세요!"

        return question
    }
}
