//
//  ViewController.swift
//  iOS Coding Challenge
//
//  Created by Krystian Grabowy on 08/07/2023.
//

import UIKit

class MovieListScreen: UIViewController {
    
    private let apiService = APIService()
    private var movieViewModel: MovieListViewModel!
    private var isSearchBarActive = false
    private var isScrollViewTriggered = false
    
    // UIs
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchBar = UISearchBar()
    private let spinner = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoriteMoviesManager = FavoriteMoviesManager()
        self.movieViewModel = MovieListViewModel(apiService: self.apiService,
                                                 favoriteMoviesManager: favoriteMoviesManager)
        self.movieViewModel.loadFavoriteMovieIds()
        self.movieViewModel.downloadData { [weak self] in
            DispatchQueue.main.async {
                self?.addSubviews()
                self?.setupSearchBar()
                self?.setupTableView()
            }
        }
    }
    
    private func setupSearchBar() {
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.searchBar.placeholder = "Search..."
        self.searchBar.delegate = self
    }
    
    private func addSubviews() {
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
    }
    
    private func setupTableView() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(MovieListTableViewCell.self, forCellReuseIdentifier: MovieListTableViewCell.identifier)
    }
    
    private func reloadTableView(mainQueue: Bool = false) {
        if mainQueue {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        } else {
            self.tableView.reloadData()
        }
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        
        self.spinner.center = footerView.center
        footerView.addSubview(self.spinner)
        self.spinner.startAnimating()
        
        return footerView
    }
    
    private func presentMovieDetailScreen(for indexPath: IndexPath) {
        let movie: Movie
        if self.isSearchBarActive {
            movie = self.movieViewModel.searchedMovies[indexPath.row]
        } else {
            movie = self.movieViewModel.data.results[indexPath.row]
        }
        let movieDetailsViewModel = MovieDetailViewModel(apiService: self.apiService)
        let isFavorite = self.movieViewModel.favoriteMovieIds.contains(movie.id)
        
        let viewControllerToPresent = MovieDetailScreen(movieDetailsViewModel: movieDetailsViewModel,
                                                        movie: movie,
                                                        isFavorite: isFavorite)
        viewControllerToPresent.view.backgroundColor = UIColor.systemBackground
        viewControllerToPresent.title = movie.original_title
        viewControllerToPresent.delegate = self
        
        let navigationController = UINavigationController(rootViewController: viewControllerToPresent)
        self.present(navigationController, animated: true)
    }
}

extension MovieListScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchBarActive {
            return self.movieViewModel.searchedMovies.count
        } else {
            return self.movieViewModel.data.results.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieListTableViewCell.identifier, for: indexPath) as! MovieListTableViewCell
        
        var movie: Movie
        if self.isSearchBarActive {
            movie = self.movieViewModel.searchedMovies[indexPath.row]
        } else {
            movie = self.movieViewModel.data.results[indexPath.row]
        }
        
        cell.titleLabel.text = movie.original_title
        
        if self.movieViewModel.favoriteMovieIds.contains(movie.id) {
            cell.favoriteButton.isSelected = true
            cell.favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        cell.favoriteButtonTappedHandler = { [weak self] in
            self?.movieViewModel.toggleFavoriteMovie(movie: movie)
            self?.reloadTableView()
        }
        
        cell.movieDetailsButtonTappedHandler = { [weak self] in
            self?.presentMovieDetailScreen(for: indexPath)
        }
        
        return cell
    }
}

extension MovieListScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MovieListScreen: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isSearchBarActive && !self.isScrollViewTriggered && self.movieViewModel.lastDownloadedPageNumber != self.movieViewModel.data.total_pages {
            let position = scrollView.contentOffset.y
            if position > (self.tableView.contentSize.height - scrollView.frame.size.height) {
                
                guard !self.apiService.isPaginating else {
                    return
                }
                
                self.isScrollViewTriggered = true
                self.tableView.tableFooterView = createSpinnerFooter()
                
                self.movieViewModel.downloadData(pagination: true) { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView.tableFooterView = nil
                    }
                    self?.reloadTableView(mainQueue: true)
                    self?.isScrollViewTriggered = false
                }
            }
        }
    }
}

extension MovieListScreen: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearchBarActive = true
        
        guard let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        self.movieViewModel.downloadSearchResults(query: query) { [weak self] in
            self?.reloadTableView(mainQueue: true)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearchBarActive = false
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.reloadTableView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
}

extension MovieListScreen: MovieDetailsScreenDelegate {
    func didToggleFavorite(movie: Movie) {
        self.movieViewModel.toggleFavoriteMovie(movie: movie)
        self.reloadTableView()
    }
}
