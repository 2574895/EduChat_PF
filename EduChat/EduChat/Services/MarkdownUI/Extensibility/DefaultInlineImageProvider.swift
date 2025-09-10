import SwiftUI

/// The default inline image provider, which provides a placeholder for images.
public struct DefaultInlineImageProvider: InlineImageProvider {
  public func image(with url: URL, label: String) async throws -> Image {
    // NetworkImage 대신 간단한 플레이스홀더 이미지 제공
    // 실제 이미지 로딩이 필요하면 NetworkImage 라이브러리를 다시 추가해야 함
    Image(systemName: "photo")
      .resizable()
      .scaledToFit()
  }
}

extension InlineImageProvider where Self == DefaultInlineImageProvider {
  /// The default inline image provider, which loads images from the network.
  ///
  /// Use the `markdownInlineImageProvider(_:)` modifier to configure
  /// this image provider for a view hierarchy.
  public static var `default`: Self {
    .init()
  }
}
