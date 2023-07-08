//
//  MovieListTableViewCell.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import UIKit

class MovieListTableViewCell: UITableViewCell {
    static let identifier = "MovieListTableViewCell"
    
    // UI's
    private let movieDetailsButton = UIButton()
    let titleLabel = UILabel()
    let favoriteButton = UIButton()
    
    // Callbacks
    var favoriteButtonTappedHandler: (() -> Void)?
    var movieDetailsButtonTappedHandler: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubviews()
        self.setupTitleLabel()
        self.setupStarImageView()
        self.setupMovieDetailsButton()
    }
    
    override func prepareForReuse() {
        self.favoriteButton.isSelected = false
        self.favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
    }
    
    private func setupMovieDetailsButton() {
        self.movieDetailsButton.translatesAutoresizingMaskIntoConstraints = false
        self.movieDetailsButton.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.movieDetailsButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.movieDetailsButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.movieDetailsButton.trailingAnchor.constraint(equalTo: self.favoriteButton.leadingAnchor).isActive = true
        
        self.movieDetailsButton.addTarget(self, action: #selector(self.movieDetailsButtonDidPress), for: .touchUpInside)
    }
    
    private func addSubviews() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.favoriteButton)
        self.contentView.addSubview(self.movieDetailsButton)
    }
    
    private func setupTitleLabel() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.favoriteButton.leadingAnchor, constant: -10).isActive = true
    }
    
    private func setupStarImageView() {
        self.favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        self.favoriteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.favoriteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        self.favoriteButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.favoriteButton.widthAnchor.constraint(equalTo: self.favoriteButton.heightAnchor).isActive = true
        
        self.favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        self.favoriteButton.addTarget(self, action: #selector(self.startButtonDidPress), for: .touchUpInside)
    }
    
    @objc func startButtonDidPress() {
        self.favoriteButtonTappedHandler?()
    }
    
    @objc func movieDetailsButtonDidPress() {
        self.movieDetailsButtonTappedHandler?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
