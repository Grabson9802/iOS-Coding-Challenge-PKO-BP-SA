//
//  APIService.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import UIKit

class APIService {
    
    var isPaginating = false
    
    func fetchImage(posterPath: String, completion: @escaping (Result<UIImage, APIError>) -> Void) {
        let baseURL = "https://image.tmdb.org/t/p/w500"
        let imageURLString = baseURL + posterPath
        
        if let imageURL = URL(string: imageURLString) {
            let session = URLSession.shared
            let task = session.dataTask(with: imageURL) { (data, response, error) in
                if error != nil {
                    completion(.failure(.requestFailed))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.requestFailed))
                    return
                }
                
                if let imageData = data,
                   let image = UIImage(data: imageData) {
                    completion(.success(image))
                }
            }
            task.resume()
        }
        completion(.failure(.invalidURL))
    }
    
    func searchData(query: String, completion: @escaping (Result<MovieListResponse, APIError>) -> Void) {
        let apiKey = "3d6fb1f945076b92f498f539b197ac7a"
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(query)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(MovieListResponse.self, from: data)
                
                completion(.success(response))
            } catch {
                completion(.failure(.parsingError))
                print("Error: \(error)")
            }
        }
        .resume()
    }
    
    func fetchData(pagination: Bool, page: Int, completion: @escaping (Result<MovieListResponse, APIError>) -> Void) {
        if pagination {
            self.isPaginating = true
        }
        
        let apiKey = "3d6fb1f945076b92f498f539b197ac7a#"
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?page=\(page)&api_key=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(.failure(.requestFailed))
                return
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(MovieListResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error with parsing data: \(error)")
                    completion(.failure(.parsingError))
                }
            }
        }
        .resume()
        
        if pagination {
            self.isPaginating = false
        }
    }
}
