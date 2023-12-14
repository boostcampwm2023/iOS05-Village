//
//  ImageUploadView.swift
//  Village
//
//  Created by 정상윤 on 12/7/23.
//

import UIKit
import Combine

final class ImageUploadView: UIView {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    private let imageViewCellReuseIdentifier = ImageViewCell.identifier
    private let cameraButtonCellReuseIdentifier = CameraButtonCell.identifier
    private let cellSize = CGSize(width: 60, height: 60)
    private let cameraButtonAction: UIAction
    private let deleteImagePublisher: PassthroughSubject<ImageItem, Never>
    private var imageCount = 0
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.isScrollEnabled = true
        view.clipsToBounds = false
        view.contentInset = .zero
        view.register(ImageViewCell.self,
                      forCellWithReuseIdentifier: imageViewCellReuseIdentifier)
        view.register(CameraButtonCell.self,
                      forCellWithReuseIdentifier: cameraButtonCellReuseIdentifier)
        
        return view
    }()
    
    private lazy var dataSource = DataSource(
        collectionView: collectionView,
        cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell in
            guard let self = self else { return UICollectionViewCell() }
            switch item {
            case .cameraButton(let count):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: self.cameraButtonCellReuseIdentifier, for: indexPath)
                        as? CameraButtonCell else { return UICollectionViewCell() }
                
                cell.addButtonAction(cameraButtonAction)
                cell.setImageCount(imageCount)
                return cell
                
            case .imageItem(let imageItem):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: self.imageViewCellReuseIdentifier, for: indexPath)
                        as? ImageViewCell else { return UICollectionViewCell() }
                
                let action = UIAction { _ in
                    self.deleteImage(item: imageItem)
                    self.deleteImagePublisher.send(imageItem)
                }
                cell.configure(imageData: imageItem.data, deleteAction: action)
                
                return cell
            }
    })
    
    init(frame: CGRect = .zero,
         cameraButtonAction: UIAction,
         deleteImagePublisher: PassthroughSubject<ImageItem, Never>) {
        self.cameraButtonAction = cameraButtonAction
        self.deleteImagePublisher = deleteImagePublisher
        
        super.init(frame: frame)
        
        addSubview(collectionView)
        setDataSource()
        setLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageItem(items: [ImageItem]) {
        appendImages(items)
    }

}

extension ImageUploadView {
    
    enum Section {
        case button
        case image
    }
    
    enum Item: Hashable {
        case cameraButton(Int)
        case imageItem(ImageItem)
    }
    
    private func setDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.button, .image])
        snapshot.appendItems([.cameraButton(imageCount)], toSection: .button)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func appendImages(_ items: [ImageItem]) {
        var snapshot = dataSource.snapshot()
        imageCount += items.count
        snapshot.reconfigureItems(snapshot.itemIdentifiers(inSection: .button))
        snapshot.appendItems(items.map { .imageItem($0) }, toSection: .image)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func deleteImage(item: ImageItem) {
        var snapshot = dataSource.snapshot()
        imageCount -= 1
        snapshot.reconfigureItems(snapshot.itemIdentifiers(inSection: .button))
        snapshot.deleteItems([.imageItem(item)])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

private extension ImageUploadView {
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
