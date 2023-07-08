//
//  MovieListResponse.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import Foundation

struct MovieListResponse: Codable {
    let page: Int
    var results: [Movie]
    let total_pages: Int
}

struct Movie: Codable {
    let id: Int
    let poster_path: String?
    let original_title: String?
    let release_date: String?
    let vote_average: Double?
    let overview: String?
}
