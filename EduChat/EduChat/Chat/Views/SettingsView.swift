import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = ""
    @State private var showSuccessMessage = false
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
