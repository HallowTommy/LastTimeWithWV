import SwiftUI

struct ActivityThumbnailView: View {
    let imagePath: String?

    private let imageStorage = ImageStorageService()

    var body: some View {
        Group {
            if let path = imagePath, let image = imageStorage.loadImage(path: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.backgroundSecondary)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.body)
                            .foregroundStyle(AppColors.textSecondary)
                    )
            }
        }
    }
}
