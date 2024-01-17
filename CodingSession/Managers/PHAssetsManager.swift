import Photos

protocol PHAssetsManagerProtocol: AnyObject {
    func fetchAssets(with type: PHAssetMediaType) -> [PHAsset]
    func getVideoAssetModel(
        from asset: PHAsset,
        with targetSize: CGSize,
        completion: @escaping (VideoAssetModel) -> Void
    )
}

final class PHAssetsManager: PHAssetsManagerProtocol {

    // MARK: - Private properties

    private let manager = PHImageManager.default()
    private let requestOptions = PHImageRequestOptions()
    private let fetchOptions = PHFetchOptions()

    private lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        formatter.unitsStyle = .positional
        return formatter
    }()

    // MARK: - Actions

    func fetchAssets(with type: PHAssetMediaType) -> [PHAsset] {
        fetchOptions.predicate = NSPredicate(
            format: "mediaType == %d",
            type.rawValue
        )

        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        var assets: [PHAsset] = []

        fetchResult.enumerateObjects { (asset, _, _) in
            assets.append(asset)
        }

        return assets
    }

    func getVideoAssetModel(
        from asset: PHAsset,
        with targetSize: CGSize,
        completion: @escaping (VideoAssetModel) -> Void
    ) {
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat

        DispatchQueue.global().async { [weak self] in
            guard let self else { return}
            self.manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: self.requestOptions
            ) { [weak self] (image, _) in

                guard let self else {
                    return
                }

                completion(
                    VideoAssetModel(
                        image: image,
                        duration: self.formatter.string(from: asset.duration)
                    )
                )
            }
        }
    }
}
