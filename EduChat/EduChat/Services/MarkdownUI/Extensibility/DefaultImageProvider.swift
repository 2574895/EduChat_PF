import SwiftUI

/// The default image provider, which provides a placeholder for images.
public struct DefaultImageProvider: ImageProvider {
  public func makeImage(url: URL?) -> some View {
    // NetworkImage 대신 간단한 플레이스홀더 이미지 제공
    // 실제 이미지 로딩이 필요하면 NetworkImage 라이브러리를 다시 추가해야 함
    Image(systemName: "photo")
      .resizable()
      .scaledToFit()
      .frame(width: 100, height: 100)
      .foregroundColor(.gray.opacity(0.5))
  }
}

extension ImageProvider where Self == DefaultImageProvider {
  /// The default image provider, which loads images from the network.
  ///
  /// Use the `markdownImageProvider(_:)` modifier to configure this image provider for a view hierarchy.
  public static var `default`: Self {
    .init()
  }
}
