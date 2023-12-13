//
//  ImagePageView.swift
//  Village
//
//  Created by 정상윤 on 11/20/23.
//

import UIKit

final class ImagePageView: UIView {
    
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
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .primary500
        pageControl.pageIndicatorTintColor = .secondaryLabel
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
    
    func setContent(_ data: [Data]) {
        configureImageViews(imageData: data)
        configurePageControl(count: data.count)
    }
    
    private func configureImageViews(imageData: [Data]) {
        imageStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        for data in imageData {
            let imageView = generateImageView(data: data)
            imageStackView.addArrangedSubview(imageView)
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
    }
    
    private func generateImageView(data: Data) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(data: data)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, 
                                                              action: #selector(presentImageDetailView(sender:))))
        
        return imageView
    }
    
    @objc
    private func presentImageDetailView(sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView,
              let data = imageView.image?.jpegData(compressionQuality: 1.0) else { return }
        
        let imageDetailView: ImageDetailView = {
            let view = ImageDetailView(imageData: data)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.alpha = 0
            
            return view
        }()
        addSubview(imageDetailView)
        setFullLayoutConstraint(child: imageDetailView, parent: self)
    }
    
    private func configurePageControl(count: Int) {
        pageControl.numberOfPages = count
    }
    
    private func setLayoutConstraints() {
        setFullLayoutConstraint(child: scrollView, parent: self)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        setFullLayoutConstraint(child: imageStackView, parent: scrollView)
    }
    
    private func setFullLayoutConstraint(child: UIView, parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }

}

extension ImagePageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(round(scrollView.contentOffset.x / self.frame.width))
    }
    
}
