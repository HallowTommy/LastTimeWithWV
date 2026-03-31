import Foundation
import UIKit

protocol ImageStorageServiceProtocol: Sendable {
    func saveImage(_ imageData: Data, for activityId: UUID) -> String?
    func loadImage(path: String) -> UIImage?
    func deleteImage(path: String)
}

final class ImageStorageService: ImageStorageServiceProtocol {
    private let fileManager = FileManager.default

    private var imagesDirectoryURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesDir = documents.appendingPathComponent(AppConstants.Storage.imagesFolder)
        if !fileManager.fileExists(atPath: imagesDir.path) {
            try? fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        return imagesDir
    }

    func saveImage(_ imageData: Data, for activityId: UUID) -> String? {
        let filename = "\(activityId.uuidString).jpg"
        let fileURL = imagesDirectoryURL.appendingPathComponent(filename)
        guard (try? imageData.write(to: fileURL)) != nil else { return nil }
        return filename
    }

    func loadImage(path: String) -> UIImage? {
        let fileURL = imagesDirectoryURL.appendingPathComponent(path)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    func deleteImage(path: String) {
        let fileURL = imagesDirectoryURL.appendingPathComponent(path)
        try? fileManager.removeItem(at: fileURL)
    }
}
