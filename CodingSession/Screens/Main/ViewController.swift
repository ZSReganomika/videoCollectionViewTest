import UIKit
import RxSwift
import SnapKit
import Accelerate
import Photos

final class ViewController: UIViewController {

    // MARK: - Private properties

    private let viewModel: ViewModelProtocol
    private let disposeBag = DisposeBag()

    private var dataSource: UICollectionViewDiffableDataSource<Section, SectionItem>!

    // MARK: - GUI

    private var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    // MARK: - Life Cycle

    init(viewModel: ViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        setupDataSource()
        viewModel.fetchAssets()
    }

    // MARK: - Data Source

    func configureDataSource(items: [PHAsset]) -> NSDiffableDataSourceSnapshot<Section, SectionItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
        snapshot.appendSections([Section.videos])
        snapshot.appendItems(
            items.map { .video($0) },
            toSection: Section.videos
        )
        return snapshot
    }

    func reloadData(items: [PHAsset]) {
        let snaphot = configureDataSource(items: items)
        dataSource.apply(
            snaphot,
            animatingDifferences: false
        )
    }

    func setupDataSource() {
          dataSource = UICollectionViewDiffableDataSource<Section, SectionItem>(
              collectionView: collectionView,
              cellProvider: { collectionView, indexPath, dataItem in
                  switch dataItem {
                  case let .video(asset):
                      guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ViewControllerCell.reuseIdentifier, for: indexPath
                      ) as? ViewControllerCell else {
                          return UICollectionViewCell()
                      }

                      cell.configureCell(asset: asset, delegate: self.viewModel)

                      return cell
                  }
          })
      }
}

// MARK: - LayoutConfigurableView

extension ViewController: LayoutConfigurableView {

    func configureSubviews() {
        view.addSubview(collectionView)
        collectionView.register(cell: ViewControllerCell.self)
        collectionView.delegate = self
    }

    func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - BindingConfigurableView

extension ViewController: BindingConfigurableView {

    func bindOutput() {
        viewModel.assets.subscribe(onNext: { [weak self] assets in
            self?.reloadData(items: assets)
        }).disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return Constants.collectionViewCellSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return .zero
    }
}

// MARK: - Constants

private enum Constants {
    static let collectionViewCellSize = CGSize(
        width: UIScreen.main.bounds.width / 3,
        height: UIScreen.main.bounds.width / 3
    )
}
