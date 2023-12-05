//
//  RentPostTableViewCell.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import UIKit

class RentPostTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureData(post: PostListResponseDTO) {
        
    }
    
}
