//
//  FavoritesService.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import Foundation

protocol FavoritesService {
    func loadFavoriteMovieIds() -> Set<Int>
    func saveFavoriteMovies(favoriteMovieIds: Set<Int>)
}
