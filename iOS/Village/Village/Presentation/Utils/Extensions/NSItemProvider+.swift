//
//  NSItemProvider+.swift
//  Village
//
//  Created by 정상윤 on 12/14/23.
//

import PhotosUI

extension NSItemProvider {
    
    func getImageData(completion: @escaping (Data?) -> Void) {
        let imageTypeIdentifiers = [
            UTType.webP.identifier,
            UTType.heic.identifier,
            UTType.rawImage.identifier
        ]
        
        if canLoadObject(ofClass: UIImage.self) {
            loadObject(ofClass: UIImage.self) { uiimage, _ in
                guard let image = uiimage as? UIImage,
                      let jpegData = image.jpegData(compressionQuality: 0.1) else { return }
                completion(jpegData)
            }
        } else {
            for identifier in imageTypeIdentifiers {
                loadFileRepresentation(forTypeIdentifier: identifier) { [weak self] url, _ in
                    if let fileURL = url,
                       let fileData = try? Data(contentsOf: fileURL),
                       let compressedData = UIImage(data: fileData)?.jpegData(compressionQuality: 0.1) {
                        self?.deleteFile(url: fileURL)
                        completion(compressedData)
                    }
                }
            }
        }
    }
    
}

fileprivate extension NSItemProvider {
    
    func deleteFile(url: URL) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            dump("File deletion failed: \(error)")
        }
        
    }
    
}
