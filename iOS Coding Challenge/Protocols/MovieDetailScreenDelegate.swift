//
//  MovieDetailScreenDelegate.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import Foundation

protocol MovieDetailsScreenDelegate: AnyObject {
    func didToggleFavorite(movie: Movie)
}
