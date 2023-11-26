//
//  HomeViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    typealias HomeDataSource = UICollectionViewDiffableDataSource<Section, PostResponseDTO>
    
    private var dataSource: HomeDataSource!
    private let reuseIdentifier = HomeCollectionViewCell.identifier
    private var collectionView: UICollectionView!
    
    private var viewModel = PostListItemViewModel()

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
        setupUI()
    }
    
    private func setupUI() {
        setNavigationUI()
        setMenuUI()
        bindFloatingButton()
        configureCollectionView()
        
        view.addSubview(floatingButton)
        view.addSubview(menuView)
        setLayoutConstraint()
    }
    
    private func bindFloatingButton() {
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

    }
    
    private func setViewModel() {
        let endpoint = APIEndPoints.getPosts(with: PostRequestDTO(page: 1))
        Task {
            do {
                guard let data = try await Provider.shared.request(with: endpoint) else { return }
                viewModel.updatePosts(data)
                configureDataSource()
                generateData()
            } catch {
                dump(error)
            }
        }
    }
    
    private func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("홈")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.backButtonDisplayMode = .minimal
        let search = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(searchButtonTapped), symbolName: .magnifyingGlass
        )
        self.navigationItem.rightBarButtonItems = [search]
        
    }
    
    private func setMenuUI() {
        let useCase = PostCreateUseCase(postCreateRepository: PostCreateRepository())
        let presentPostRequestNC = UIAction(title: "대여 요청하기") { [weak self] _ in
            let requestViewModel = PostCreateViewModel(useCase: useCase, postType: .request)
            let postRequestVC = PostCreateViewController(viewModel: requestViewModel, type: .request)
            let postRequestNC = UINavigationController(rootViewController: postRequestVC)
            postRequestNC.modalPresentationStyle = .fullScreen
            self?.present(postRequestNC, animated: true)
        }
        let presentPostRentNC = UIAction(title: "대여 등록하기") { [weak self] _ in
            let rentViewModel = PostCreateViewModel(useCase: useCase, postType: .rent)
            let postRentVC = PostCreateViewController(viewModel: rentViewModel, type: .rent)
            let postRentNC = UINavigationController(rootViewController: postRentVC)
            postRentNC.modalPresentationStyle = .fullScreen
            self?.present(postRentNC, animated: true)
        }
        menuView.setMenuActions([presentPostRequestNC, presentPostRentNC])
    }
    
    @objc func searchButtonTapped() {
        let nextVC = SearchViewController()
        let presentSearchNV = UINavigationController(rootViewController: nextVC)
        presentSearchNV.modalPresentationStyle = .fullScreen
        self.present(presentSearchNV, animated: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
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
            
            if let imageURL = post.images.first {
                let endpoint = APIEndPoints.getData(with: imageURL)
                Task {
                    do {
                        let data = try await Provider.shared.request(from: endpoint.baseURL)
                        cell.configureImage(image: UIImage(data: data))
                    } catch {
                        dump(error)
                    }
                }
            } else {
                cell.configureImage(image: nil)
            }
            
            return cell
        }
    }
    
    private func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostResponseDTO>()
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

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = viewModel.getPost(indexPath.row)
        
        if (post.isRequest != 0) {
            self.navigationController?.pushViewController(RequestDetailViewController(post: post), animated: true)
        } else {
            self.navigationController?.pushViewController(RentDetailViewController(postData: post), animated: true)
        }
    }
    
}
