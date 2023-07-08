//
//  FavoriteMoviesManager.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import Foundation

struct FavoriteMoviesManager: FavoritesService {
    private let userDefaults = UserDefaults.standard
    private let favoriteMovieIdsKey = "FavoriteMovieIds"
    
    func loadFavoriteMovieIds() -> Set<Int> {
        if let favoriteIds = userDefaults.array(forKey: favoriteMovieIdsKey) as? [Int] {
            return Set(favoriteIds)
        }
        return Set()
    }
    
    func saveFavoriteMovies(favoriteMovieIds: Set<Int>) {
        userDefaults.set(Array(favoriteMovieIds), forKey: favoriteMovieIdsKey)
    }
}
