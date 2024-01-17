import UIKit
import Photos

protocol ImageLoadingDelegate: AnyObject {
    func loadImage(from: PHAsset, size: CGSize, completion: @escaping (VideoAssetModel) -> Void)
}

final class ViewControllerCell: UICollectionViewCell {

    // MARK: - GUI

    private var thumbImageView = UIImageView(frame: .zero)
    private var durationLabel = UILabel(frame: .zero)
    private var activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Private properties

    private weak var imageLoadingDelegate: ImageLoadingDelegate?

    // MARK: - Life Cycle

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbImageView.image = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    func configureCell(asset: PHAsset, delegate: ImageLoadingDelegate) {
        activityIndicator.startAnimating()

        imageLoadingDelegate = delegate
        imageLoadingDelegate?.loadImage(
            from: asset,
            size: Constants.resultImageSize,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.thumbImageView.image = result.image
                    self?.durationLabel.text = result.duration
                }
            }
        )
    }
}

// MARK: - LayoutConfigurableView

extension ViewControllerCell: LayoutConfigurableView {

    func configureSubviews() {
        contentView.addSubview(thumbImageView)
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true

        contentView.addSubview(durationLabel)
        contentView.addSubview(activityIndicator)
    }

    func configureLayout() {
        activityIndicator.center = contentView.center

        thumbImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        durationLabel.snp.makeConstraints {
            $0.leading.equalTo(Constants.durationLabelLeading)
            $0.bottom.equalTo(Constants.durationLabelBottom)
        }
    }
}

// MARK: - Constants

private enum Constants {
    static let durationLabelLeading = 8
    static let durationLabelBottom = -8

    static let resultImageSize = CGSize(
        width: UIScreen.main.bounds.width / 3,
        height: UIScreen.main.bounds.width / 3
    )
}
