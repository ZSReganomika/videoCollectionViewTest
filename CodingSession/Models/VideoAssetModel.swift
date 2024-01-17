import UIKit
import Photos

struct VideoAssetModel {
    var image: UIImage?
    var duration: String?
}

enum Section: Hashable {
    case videos
}

enum SectionItem: Hashable {
    case video(PHAsset)
}

struct SectionData {
    var key: Section
    var values: [SectionItem]
}
