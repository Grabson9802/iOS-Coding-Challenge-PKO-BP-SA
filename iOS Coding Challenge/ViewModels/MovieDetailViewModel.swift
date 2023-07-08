//
//  MovieDetailViewModel.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import UIKit

class MovieDetailViewModel {
    
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func downloadImage(posterPath: String, completion: @escaping (UIImage?) -> Void ) {
        self.apiService.fetchImage(posterPath: posterPath) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(let failure):
                print("Error fetching movies \(failure.localizedDescription)")
                completion(nil)
            }
        }
    }
}
