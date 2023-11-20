//
//  PostDetailViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/17.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    var postData: Post?
    
    init(postData: Post? = nil) {
        self.postData = postData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}