# MarkdownUI 라이브러리 추가 가이드

## 🎯 MarkdownUI 소개
SwiftUI에서 마크다운을 아름답게 렌더링하는 라이브러리
- GitHub: https://github.com/gonzalezreal/swift-markdown-ui
- SwiftUI 네이티브 지원
- 풍부한 마크다운 기능 지원

## 📋 Xcode에서 추가하기

### 1단계: Xcode 열기
```bash
open EduChat.xcodeproj
```

### 2단계: Swift Package Manager 열기
```
Xcode 메뉴 → File → Add Packages...
```

### 3단계: 패키지 URL 입력
```
https://github.com/gonzalezreal/swift-markdown-ui
```

### 4단계: 버전 선택
- **Up to Next Major**: 가장 안전한 옵션
- **Version 2.0.0 이상** 권장

### 5단계: 타겟 선택
- EduChat 타겟에 추가

## 🔧 코드 활성화

### MessageBubble.swift에서 주석 해제
```swift
// 1. import 추가 (라인 2)
import MarkdownUI  // 주석 제거

// 2. MarkdownUI 사용 부분 주석 해제 (라인 68-100)
// 현재 주석 처리된 Markdown 컴포넌트 부분을 활성화하세요
if #available(macOS 12.0, *) {
    Markdown(markdownContent)
        .markdownTheme(.gitHub) // 깔끔한 GitHub 스타일
        .padding(14)
        .background(Color.secondary.opacity(isHovered ? 0.4 : 0.2))
        // ... 나머지 스타일
}
```

## 🚨 긴급 문제 해결 (현재 에러 발생 시)

### "No such module 'MarkdownUI'" 에러 해결
```bash
# 1. Xcode 완전히 닫기
# 2. 터미널에서 프로젝트 열기
open EduChat.xcodeproj

# 3. DerivedData 삭제 (캐시 문제 해결)
rm -rf ~/Library/Developer/Xcode/DerivedData

# 4. Clean Build
# Xcode 메뉴: Product → Clean Build Folder (⌘+Shift+K)

# 5. 다시 빌드
# Xcode 메뉴: Product → Build (⌘+B)
```

### 4단계: 패키지 재추가 확인
```
Xcode Navigator (왼쪽) → EduChat → Dependencies
- MarkdownUI가 목록에 있는지 확인
- 없으면 다시 Add Packages... 진행
```

## 🎨 MarkdownUI 장점

- ✅ **자동 마크다운 파싱**: 수동 변환 불필요
- ✅ **풍부한 스타일링**: 테이블, 코드블록, 리스트 등
- ✅ **SwiftUI 통합**: 네이티브 컴포넌트 사용
- ✅ **성능 최적화**: 효율적인 렌더링
- ✅ **접근성 지원**: 스크린 리더 호환

## 🔄 현재 vs MarkdownUI

| 기능 | 현재 방식 | MarkdownUI |
|:-----|:----------|:-----------|
| **복잡도** | 보통 | 쉬움 |
| **스타일링** | 제한적 | 풍부 |
| **유지보수** | 복잡 | 간단 |
| **성능** | 양호 | 최적 |
| **의존성** | 없음 | 있음 |

## 🚀 업그레이드 효과

### 기존 AIResponseFormatter 역할 축소
- 복잡한 텍스트 변환 로직 제거
- 간단한 마크다운 헤더 추가만 수행
- MarkdownUI가 나머지 렌더링 담당

### 향상된 사용자 경험
- 더 깔끔한 마크다운 표시
- 코드블록, 테이블 등 지원
- 더 빠른 렌더링 속도

## 💡 추천 워크플로우

1. **MarkdownUI 추가**
2. **MessageBubble에서 코드 활성화**
3. **AIResponseFormatter 단순화**
4. **테스트 및 최적화**

---

## ⚠️ 주의사항

- **macOS 12.0+ 필수**: MarkdownUI는 Monterey 이상 필요
- **SwiftUI 호환성**: 프로젝트의 SwiftUI 버전 확인
- **빌드 시간**: 패키지 추가로 빌드 시간이 약간 증가할 수 있음

## 🎯 결론

**MarkdownUI는 EduChat의 마크다운 렌더링을 한 단계 업그레이드할 것입니다!** 🚀✨
