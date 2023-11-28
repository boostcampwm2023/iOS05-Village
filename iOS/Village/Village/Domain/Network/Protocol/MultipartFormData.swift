//
//  MultipartFormData.swift
//  Village
//
//  Created by 정상윤 on 11/28/23.
//

import Foundation

protocol MultipartFormData {
    var boundary: String { get }
    var httpBody: Data { get }
}
