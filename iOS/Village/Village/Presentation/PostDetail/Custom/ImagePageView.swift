//
//  ImagePageView.swift
//  Village
//
//  Created by 정상윤 on 11/20/23.
//

import UIKit

final class ImagePageView: UIView {
    
    private var imageURL = [String]()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private var imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.backgroundStyle = .minimal
        return pageControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.delegate = self
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        scrollView.delegate = self
        configureUI()
    }
    
    private func configureUI() {
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        scrollView.addSubview(imageStackView)
        
        setLayoutConstraints()
    }
    
    func setImageURL(_ url: [String]) {
        self.imageURL = url
        
        configurePageControl()
        configureImageViews()
    }
    
    private func configureImageViews() {
        for (index, url) in self.imageURL.enumerated() {
            Task {
                do {
                    let data = try await NetworkService.loadData(from: url)
                    let imageView = generateImageView(data: data, index: index)
                    imageStackView.addArrangedSubview(imageView)
                    imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
                    imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
                } catch let error {
                    dump(error)
                }
            }
        }
    }
    
    private func generateImageView(data: Data, index: Int) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(data: data)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private func configurePageControl() {
        pageControl.numberOfPages = imageURL.count
        
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

}

extension ImagePageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(round(scrollView.contentOffset.x / self.frame.width))
    }
    
}
