//
//  HomeViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    typealias HomeDataSource = UICollectionViewDiffableDataSource<Section, Post>
    
    private var dataSource: HomeDataSource!
    private let reuseIdentifier = HomeCollectionViewCell.identifier
    private var collectionView: UICollectionView!
    
    private var viewModel = PostListItemViewModel()
    private var networkService = NetworkService()

    private let floatingButton: FloatingButton = {
        let button = FloatingButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuView: MenuView = {
        let menu = MenuView()
        menu.isHidden = true
        menu.translatesAutoresizingMaskIntoConstraints = false
        return menu
    }()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewModel()
        floatingButton.$isActive
            .sink(receiveValue: { [weak self] isActive in
                switch isActive {
                case true:
                    self?.menuView.fadeIn()
                case false:
                    self?.menuView.fadeOut()
                }
            })
            .store(in: &cancellableBag)
        
        setupUI()
        generateData()
    }
    
    private func setupUI() {
        setNavigationUI()
        setMenuUI()
        configureCollectionView()
        configureDataSource()
        
        view.addSubview(floatingButton)
        view.addSubview(menuView)
        setLayoutConstraint()
    }
    
    private func setViewModel() {
        guard let path = Bundle.main.path(forResource: "Post", ofType: "json") else { return }
        
        guard let jsonString = try? String(contentsOfFile: path) else { return }
        do {
            let decoder = JSONDecoder()
            let data = jsonString.data(using: .utf8)
            
            guard let data = data else { return }
            let posts = try decoder.decode(PostResponse.self, from: data)
            viewModel.updatePosts(updatePosts: posts.body)
        } catch {
            return
        }
    }
    
    private func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("홈")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let search = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(search), symbolName: .magnifyingGlass
        )
        self.navigationItem.rightBarButtonItems = [search]
        
    }
    
    private func setMenuUI() {
        let presentPostRequestVC = UIAction(title: "대여 요청하기") { _ in
            // TODO: 요청 게시글 화면 이동
        }
        let presentPostRentVC = UIAction(title: "대여 등록하기") { _ in
            let postRentVC = PostingRentViewController()
            postRentVC.modalPresentationStyle = .fullScreen
            self.present(postRentVC, animated: true)
        }
        menuView.setMenuActions([presentPostRequestVC, presentPostRentVC])
    }
    
    @objc func search() {
        // TODO: 검색버튼액션 구현
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        section.contentInsets = .init(top: 10.0, leading: 0.0, bottom: 4.0, trailing: 0.0)
        section.interGroupSpacing = 8.0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        dataSource = HomeDataSource(collectionView: collectionView) { (collectionView, indexPath, post) ->
            UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.reuseIdentifier,
                for: indexPath
            ) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configureData(post: post)
            
            if let imageURL = post.images.first, let postImageURL = URL(string: imageURL) {
                self.networkService.loadImage(from: postImageURL) { [weak cell] data in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell?.configureImage(image: image)
                        }
                    }
                }
            } else {
                cell.configureImage(image: nil)
            }
            
            return cell
        }
    }
    
    private func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(viewModel.getPosts())
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setLayoutConstraint() {
        NSLayoutConstraint.activate([
            floatingButton.widthAnchor.constraint(equalToConstant: 65),
            floatingButton.heightAnchor.constraint(equalToConstant: 65),
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            menuView.widthAnchor.constraint(equalToConstant: 150),
            menuView.heightAnchor.constraint(equalToConstant: 100),
            menuView.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor, constant: 0),
            menuView.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -15)
        ])
    }
}
