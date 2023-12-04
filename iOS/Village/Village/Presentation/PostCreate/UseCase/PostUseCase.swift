//
//  PostUseCase.swift
//  Village
//
//  Created by 조성민 on 12/4/23.
//

import Foundation

protocol PostUseCase {
    
    func execute(with: PostModifyDTO)
    
}
