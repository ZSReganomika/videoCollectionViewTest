import Foundation
import RxSwift
import Photos

protocol ViewModelProtocol: AnyObject, ImageLoadingDelegate {
    var assets: PublishSubject<[PHAsset]> { get }

    func fetchAssets()
}

final class ViewModel: ViewModelProtocol {

    // MARK: - Private properties

    private let disposeBag = DisposeBag()
    private var assetsManager: PHAssetsManagerProtocol

    // MARK: - ViewModelProtocol properties

    var assets = PublishSubject<[PHAsset]>()

    // MARK: - Initialization

    init(assetsManager: PHAssetsManagerProtocol) {
        self.assetsManager = assetsManager
    }

    // MARK: - ViewModelProtocol actions

    func fetchAssets() {
        assets.onNext(assetsManager.fetchAssets(with: .video))
    }
}

// MARK: - ImageLoadingDelegate

extension ViewModel {
    func loadImage(from: PHAsset, size: CGSize, completion: @escaping (VideoAssetModel) -> Void) {
        assetsManager.getVideoAssetModel(from: from, with: size) { asset in
            completion(asset)
        }
    }
}
