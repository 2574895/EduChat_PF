import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = ""
    @State private var showSuccessMessage = false
    @State private var showThemeChangeMessage = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("EduChat 설정")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                Text("OpenAI API 키")
                    .font(.headline)

                TextField("sk-...로 시작하는 API 키를 입력하세요", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onAppear {
                        // 저장된 API 키 불러오기
                        if let savedKey = UserDefaults.standard.string(forKey: "openai_api_key") {
                            apiKey = savedKey
                        }
                    }

                Text("API 키는 안전하게 저장되며 채팅 기능에만 사용됩니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding()

            VStack(alignment: .leading, spacing: 15) {
                Text("외모 설정")
                    .font(.headline)

                HStack {
                    ZStack {
                        Circle()
                            .fill(isDarkMode ? Color.black : Color.white)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .white : .orange)
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 12)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isDarkMode ? "다크 모드" : "라이트 모드")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("앱의 색상 테마를 변경합니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $isDarkMode)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle())
                        .onChange(of: isDarkMode) { _, _ in
                            showThemeChangeMessage = true
                            // 3초 후 메시지 숨기기
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showThemeChangeMessage = false
                            }
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .padding()


            HStack(spacing: 20) {
                Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)

                Button("저장") {
                    saveAPIKey()
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)

            if showSuccessMessage {
                Text("API 키가 저장되었습니다!")
                    .foregroundColor(.green)
                    .padding()
                    .transition(.opacity)
            }

            if showThemeChangeMessage {
                Text("테마가 변경되었습니다! 앱을 재시작하면 적용됩니다.")
                    .foregroundColor(.blue)
                    .font(.caption)
                    .padding(.horizontal)
                    .transition(.opacity)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }

    private func saveAPIKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }

        UserDefaults.standard.set(trimmedKey, forKey: "openai_api_key")
        showSuccessMessage = true

        // 2초 후 성공 메시지 숨기기
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSuccessMessage = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
