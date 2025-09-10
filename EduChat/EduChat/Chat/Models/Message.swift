import Foundation

struct Message: Identifiable, Codable {
  var id = UUID()
  let content: String
  let isFromUser: Bool
  let timestamp: Date
  var searchResults: [SearchResultItem]? = nil
  // Minimal initializer for reusable skeleton
  init(content: String, isFromUser: Bool, searchResults: [SearchResultItem]? = nil) {
    self.content = content
    self.isFromUser = isFromUser
    self.timestamp = Date()
    self.searchResults = searchResults
  }
}

struct SearchResultItem: Codable, Identifiable {
  let id = UUID()
  let title: String
  let snippet: String
  let url: String
}
