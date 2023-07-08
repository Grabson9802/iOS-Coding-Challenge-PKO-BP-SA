//
//  APIError.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case parsingError
}
