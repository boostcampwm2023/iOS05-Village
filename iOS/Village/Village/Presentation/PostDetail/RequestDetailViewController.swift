//
//  RequestDetailViewController.swift
//  Village
//
//  Created by 정상윤 on 11/22/23.
//

import UIKit

final class RequestDetailViewController: UIViewController {
    
    private let post: Post
    
    init(post: Post) {
        self.post = post
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("Should not be called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
}

private extension RequestDetailViewController {
    
    func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
}
