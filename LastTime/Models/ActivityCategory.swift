import Foundation

struct ActivityCategory: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var iconAssetName: String?
    var colorHex: String

    init(
        id: UUID = UUID(),
        name: String,
        iconAssetName: String? = nil,
        colorHex: String
    ) {
        self.id = id
        self.name = name
        self.iconAssetName = iconAssetName
        self.colorHex = colorHex
    }
}
