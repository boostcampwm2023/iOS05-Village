//
//  HomeViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit

class HomeViewController: UIViewController {
    
    typealias HomeDataSource = UICollectionViewDiffableDataSource<Section, String>
    
    private var dataSource: HomeDataSource!
    private let reuseIdentifier = "HomeCollectionViewCell"
    private var collectionView: UICollectionView!
    
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationUI()
        configureCollectionView()
        configureDataSource()
        generateData()
    }
    
    private func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("홈")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let search = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(search), symbolName: "magnifyingglass"
        )
        self.navigationItem.rightBarButtonItems = [search]
        
    }
    
    @objc func search() {
        
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .green
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100.0)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10.0, leading: 20.0, bottom: 4.0, trailing: 20.0)
        section.interGroupSpacing = 8.0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        dataSource = HomeDataSource(collectionView: collectionView) { (collectionView, indexPath, item) ->
            UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.reuseIdentifier,
                for: indexPath
            ) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.label.text = item
            cell.backgroundColor = .blue
            return cell
        }
    }
    
    private func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        
        let items = ["12123","12","13","14","15","16","17","18","19","asd","qweqwe", "1231424", "1241243123", "121231234123", "1123123", "adsasd", "13213asda", "q", "zxc", "zxcvasd", "vsdacv", "ber"]
        
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
