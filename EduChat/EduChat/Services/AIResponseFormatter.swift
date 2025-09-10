import Foundation

/// AI 응답의 출력 형식을 구조화하여 마크다운으로 변환하는 포맷터
final class AIResponseFormatter {

    // MARK: - Public Interface

    /// AI 응답을 지정된 모드에 맞게 마크다운 형식으로 변환
    /// - Parameters:
    ///   - response: 원본 AI 응답 텍스트
    ///   - mode: AI 모드 (.normal 또는 .deepLearning)
    /// - Returns: 마크다운 형식으로 변환된 텍스트
    func format(_ response: String, mode: AIMode) -> String {
        switch mode {
        case .normal:
            return formatNormalMode(response)
        case .deepLearning:
            return formatDeepLearningMode(response)
        }
    }

    // MARK: - Private Methods

    /// 일반 모드 응답 포맷팅
    private func formatNormalMode(_ response: String) -> String {
        let patterns = NormalModePattern.allCases
        return applyPatterns(response, patterns: patterns)
    }

    /// 딥러닝 모드 응답 포맷팅
    private func formatDeepLearningMode(_ response: String) -> String {
        let patterns = DeepLearningModePattern.allCases
        return applyPatterns(response, patterns: patterns)
    }

    /// 패턴들을 적용하여 응답을 변환
    private func applyPatterns(_ response: String, patterns: [ResponsePattern]) -> String {
        var formatted = response

        for pattern in patterns {
            if formatted.contains(pattern.searchText) {
                formatted = formatted.replacingOccurrences(of: pattern.searchText, with: pattern.replacement)
            }
        }

        // 최종 정리
        return finalizeFormatting(formatted)
    }

    /// 최종 포맷팅 정리 (빈 줄 정리, 공백 제거 등)
    private func finalizeFormatting(_ text: String) -> String {
        var formatted = text

        // 과도한 빈 줄 정리
        formatted = formatted.replacingOccurrences(of: "\n\n\n\n", with: "\n\n\n")

        // 시작과 끝의 공백/줄바꿈 정리
        formatted = formatted.trimmingCharacters(in: .whitespacesAndNewlines)

        return formatted
    }
}

// MARK: - Supporting Types

/// AI 모드 열거형
enum AIMode {
    case normal
    case deepLearning
}

/// 응답 패턴 프로토콜
protocol ResponsePattern {
    var searchText: String { get }
    var replacement: String { get }
}

/// 일반 모드 패턴들
enum NormalModePattern: CaseIterable, ResponsePattern {
    case summary
    case history

    var searchText: String {
        switch self {
        case .summary: return "비유를 통한 핵심 요약"
        case .history: return "개념의 역사"
        }
    }

    var replacement: String {
        switch self {
        case .summary: return "\n\n### 비유를 통한 핵심 요약\n\n"
        case .history: return "\n\n### 개념의 역사\n\n"
        }
    }
}

/// 딥러닝 모드 패턴들
enum DeepLearningModePattern: CaseIterable, ResponsePattern {
    case concept
    case analysis
    case principle
    case application
    case history
    case limitation

    var searchText: String {
        switch self {
        case .concept: return "개념의 핵심 본질 파악"
        case .analysis: return "표면과 관계성 분석"
        case .principle: return "원리와 구현 방법"
        case .application: return "응용과 활용 분야"
        case .history: return "역사적 발전과 맥락"
        case .limitation: return "한계와 미래 전망"
        }
    }

    var replacement: String {
        switch self {
        case .concept: return "\n\n## 1. 개념의 핵심 본질 파악\n\n"
        case .analysis: return "\n\n## 2. 표면과 관계성 분석\n\n"
        case .principle: return "\n\n## 3. 원리와 구현 방법\n\n"
        case .application: return "\n\n## 4. 응용과 활용 분야\n\n"
        case .history: return "\n\n## 5. 역사적 발전과 맥락\n\n"
        case .limitation: return "\n\n## 6. 한계와 미래 전망\n\n"
        }
    }
}
