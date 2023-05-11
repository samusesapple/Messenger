////
////  StorageManager.swift
////  Messenger
////
////  Created by Sam Sung on 2023/05/07.
////
//
//import Foundation
//import FirebaseStorage
//
//final class StorageManager {
//    
//    // MARK: - Errors
//    
//    public enum StorageErrors: Error {
//        case failedToUpload
//        case failedDownloadingURL
//    }
//    
//    // MARK: - StorageManager
//    
//    static let shared = StorageManager()
//    private init() { }
//    
//    private let storage = Storage.storage().reference()
//    
//    typealias UploadPictureCompletion = (Result<String, Error>) -> Void
//    
//    /// Upload picture to firebase storage  > returns completion with urlString to download
//    func uploadProfilePicutre(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
//        storage.child("images/\(fileName)").putData(data) { [weak self] metadata, error in
//            guard error == nil else {
//                print("Firebase에 이미지 데이터 업로드 실패")
//                completion(.failure(StorageErrors.failedToUpload))
//                return
//            }
//            self?.storage.child("images/\(fileName)").downloadURL { url, error in
//                guard let url = url else {
//                    completion(.failure(StorageErrors.failedDownloadingURL))
//                    return
//                }
//                let urlString = url.absoluteString
//                print("URL 다운로드 및 문자열 변환해서 Firebase에 저장 성공")
//            }
//        }
//    }
//    
//    func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        let reference = storage.child(path)
//        print(#function)
//        reference.downloadURL { url, error in
//            guard let url = url, error == nil else {
//                completion(.failure(StorageErrors.failedDownloadingURL))
//                return
//            }
//            completion(.success(url))
//        }
//    }
//}
