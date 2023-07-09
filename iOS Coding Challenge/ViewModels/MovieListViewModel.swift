//
//  MovieListViewModel.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import Foundation

class MovieListViewModel {
    
    private let apiService: APIService
    private let favoriteMoviesManager: FavoriteMoviesManager
    
    var data = MovieListResponse(page: 0, results: [], total_pages: 0)
    var searchedMovies = [Movie]()
    var favoriteMovieIds = Set<Int>()
    var lastDownloadedPageNumber = 0
    
    init(apiService: APIService, favoriteMoviesManager: FavoriteMoviesManager) {
        self.apiService = apiService
        self.favoriteMoviesManager = favoriteMoviesManager
    }
    
    func toggleFavoriteMovie(movie: Movie) {
        if self.favoriteMovieIds.contains(movie.id) {
            self.favoriteMovieIds.remove(movie.id)
        } else {
            self.favoriteMovieIds.insert(movie.id)
        }
        self.saveFavoriteMovies()
    }
    
    func loadFavoriteMovieIds() {
        self.favoriteMovieIds = self.favoriteMoviesManager.loadFavoriteMovieIds()
    }
    
    func saveFavoriteMovies() {
        self.favoriteMoviesManager.saveFavoriteMovies(favoriteMovieIds: self.favoriteMovieIds)
    }
    
    func downloadSearchResults(query: String, completion: (() -> Void)?) {
        self.apiService.searchData(query: query) { [weak self] result in
            if let data = self?.handleResult(result: result) {
                self?.searchedMovies = data.results
                completion?()
            }
        }
    }
    
    func downloadData(pagination: Bool = false, completion: (() -> Void)?) {
        self.apiService.fetchData(pagination: pagination, page: self.lastDownloadedPageNumber + 1) { [weak self] result in
            if let data = self?.handleResult(result: result) {
                self?.data.results.append(contentsOf: data.results)
                self?.lastDownloadedPageNumber = data.page
                completion?()
            }
        }
    }
    
    private func handleResult(result: Result<MovieListResponse, APIError>) -> MovieListResponse? {
        switch result {
        case .success(let movies):
            return movies
        case .failure(let failure):
            print("Error fetching movies \(failure.localizedDescription)")
            return nil
        }
    }
}
