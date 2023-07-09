//
//  MovieDetailScreen.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import UIKit

class MovieDetailScreen: UIViewController {
    
    private let movieDetailsViewModel: MovieDetailViewModel
    private let movie: Movie
    private var isFavorite: Bool
    
    // UIs
    private let posterImageView = UIImageView()
    private let overviewLabel = UILabel()
    private let releaseDateLabel = UILabel()
    private let ratingLabel = UILabel()
    private let spinnerView = UIActivityIndicatorView()
    private let nonePosterLabel = UILabel()
    
    // Delegates
    weak var delegate: MovieDetailsScreenDelegate?
    
    init(movieDetailsViewModel: MovieDetailViewModel, movie: Movie, isFavorite: Bool) {
        
        self.movieDetailsViewModel = movieDetailsViewModel
        self.movie = movie
        self.isFavorite = isFavorite
        
        super.init(nibName: nil, bundle: nil)
        
        self.setFavoriteBarButtonState()
        self.addSubviews()
        self.setupSpinnerView()
        self.setupPosterImageView()
        self.setupOverviewLabel()
        self.setupReleaseDateLabel()
        self.setupRatingLabel()
    }
    
    private func setFavoriteBarButtonState() {
        let imageToSet = self.isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        let favoriteBarButtonItem = UIBarButtonItem(image: imageToSet, style: .plain, target: self, action: #selector(self.toggleFavorite))
        self.navigationItem.rightBarButtonItem = favoriteBarButtonItem
    }
    
    @objc func toggleFavorite() {
        if self.isFavorite {
            self.isFavorite = false
        } else {
            self.isFavorite = true
        }
        
        self.setFavoriteBarButtonState()
        self.delegate?.didToggleFavorite(movie: movie)
    }
    
    private func addSubviews() {
        self.view.addSubview(self.posterImageView)
        self.view.addSubview(self.spinnerView)
        self.view.addSubview(self.overviewLabel)
        self.view.addSubview(self.releaseDateLabel)
        self.view.addSubview(self.ratingLabel)
    }
    
    private func setupRatingLabel() {
        self.ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.ratingLabel.topAnchor.constraint(equalTo: self.releaseDateLabel.bottomAnchor, constant: 10).isActive = true
        self.ratingLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.ratingLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        self.ratingLabel.text = "Rating: \(self.movie.vote_average ?? 0)"
    }
    
    private func setupReleaseDateLabel() {
        self.releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.releaseDateLabel.topAnchor.constraint(equalTo: self.overviewLabel.bottomAnchor, constant: 50).isActive = true
        self.releaseDateLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.releaseDateLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        self.releaseDateLabel.text = "Release date: \(self.movie.release_date ?? "-")"
    }
    
    private func setupOverviewLabel() {
        self.overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        self.overviewLabel.topAnchor.constraint(equalTo: self.posterImageView.bottomAnchor, constant: 10).isActive = true
        self.overviewLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.overviewLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        self.overviewLabel.numberOfLines = 0
        self.overviewLabel.text = self.movie.overview
    }
    
    private func setupPosterImageView() {
        self.posterImageView.translatesAutoresizingMaskIntoConstraints = false
        self.posterImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        self.posterImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.posterImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        self.posterImageView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 3).isActive = true
        
        self.posterImageView.contentMode = .scaleAspectFit
        
        if let posterPath = self.movie.poster_path {
            self.movieDetailsViewModel.downloadImage(posterPath: posterPath) { image in
                DispatchQueue.main.async { [weak self] in
                    self?.posterImageView.image = image
                    self?.stopSpinner()
                }
            }
        } else {
            self.handleNonePoster()
        }
    }
    
    private func stopSpinner() {
        self.spinnerView.stopAnimating()
        self.spinnerView.removeFromSuperview()
    }
    
    private func handleNonePoster() {
        self.stopSpinner()
        self.view.addSubview(self.nonePosterLabel)
        self.setupNonePosterLabel()
    }
    
    private func setupNonePosterLabel() {
        self.nonePosterLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nonePosterLabel.centerXAnchor.constraint(equalTo: self.posterImageView.centerXAnchor).isActive = true
        self.nonePosterLabel.centerYAnchor.constraint(equalTo: self.posterImageView.centerYAnchor).isActive = true
        
        self.nonePosterLabel.text = "No poster"
    }
    
    private func setupSpinnerView() {
        self.spinnerView.translatesAutoresizingMaskIntoConstraints = false
        self.spinnerView.centerXAnchor.constraint(equalTo: self.posterImageView.centerXAnchor).isActive = true
        self.spinnerView.centerYAnchor.constraint(equalTo: self.posterImageView.centerYAnchor).isActive = true
        
        self.spinnerView.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
