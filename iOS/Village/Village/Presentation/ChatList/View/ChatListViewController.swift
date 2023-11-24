//
//  ChatListViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/23.
//

import UIKit

class ChatListViewController: UIViewController {
//    
//    typealias ChatListDataSource = UICollectionViewDiffableDataSource<Section, PostResponseDTO>
//    
//    private var dataSource: ChatListDataSource!
//    private let reuseIdentifier = ChatListCollectionViewCell.identifier
//    private var collectionView: UICollectionView!
//    
//    private var viewModel = PostListItemViewModel()
//    
//    enum Section {
//        case chat
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()

//        setViewModel()
        setUI()
//        generateData()
    }
//    
    private func setUI() {
        view.backgroundColor = .systemBackground
        
//        setNavigationUI()
//        configureCollectionView()
//        configureDataSource()
    }
//    
//    private func setViewModel() {
////        MARK: 더미데이터를 위한 코드 채팅API 구현 후, 삭제 예정
////        guard let path = Bundle.main.path(forResource: "Post", ofType: "json") else { return }
////        
////        guard let jsonString = try? String(contentsOfFile: path) else { return }
////        do {
////            let decoder = JSONDecoder()
////            let data = jsonString.data(using: .utf8)
////            
////            guard let data = data else { return }
////            let posts = try decoder.decode([PostResponseDTO].self, from: data)
////            viewModel.updatePosts(posts)
////            print(viewModel.getPosts())
////        } catch {
////            return
////        }
//        
//        let endpoint = APIEndPoints.getPosts(with: PostRequestDTO(page: 1))
//        Task {
//            do {
//                let data = try await Provider.shared.request(with: endpoint)
//                viewModel.updatePosts(data)
//                configureDataSource()
//                generateData()
//            } catch {
//                dump(error)
//            }
//        }
//    }
//
//    private func setNavigationUI() {
//        let titleLabel = UILabel()
//        titleLabel.setTitle("채팅")
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
//        self.navigationItem.backButtonDisplayMode = .minimal
//    }
//    
//    private func configureCollectionView() {
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.delegate = self
//        view.addSubview(collectionView)
//    }
//    
//    private func createLayout() -> UICollectionViewLayout {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .fractionalHeight(1.0)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(80.0)
//        )
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = .init(top: 10.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
//        section.interGroupSpacing = 0.0
//        
//        return UICollectionViewCompositionalLayout(section: section)
//    }
//    
//    private func configureDataSource() {
//        collectionView.register(ChatListCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        dataSource = ChatListDataSource(collectionView: collectionView) { (collectionView, indexPath, post) ->
//            UICollectionViewCell? in
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: self.reuseIdentifier,
//                for: indexPath
//            ) as? ChatListCollectionViewCell else {
//                return UICollectionViewCell()
//            }
//            
//            cell.configureData(data: post)
//            
//            if let imageURL = post.images.first {
//                Task {
//                    do {
//                        let data = try await NetworkService.loadData(from: imageURL)
//                        cell.configureImage(image: UIImage(data: data))
//                    } catch let error {
//                        dump(error)
//                    }
//                }
//            } else {
//                cell.configureImage(image: nil)
//            }
//            
//            return cell
//        }
//    }
//    
//    private func generateData() {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, PostResponseDTO>()
//        snapshot.appendSections([.chat])
//        snapshot.appendItems(viewModel.getPosts())
//        
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//}
//
//extension ChatListViewController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//    }
//    
}
