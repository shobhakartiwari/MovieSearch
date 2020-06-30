//
//  DetailsViewController.swift
//  MovieSearch


import UIKit
import Kingfisher

class DetailsViewController: UIViewController {

    let movieVM = MoviesViewModel()
    var movieDetail: MovieDetail?
    var movie: Results?
    var movieGenre: String?
    var movieId: Int?
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var movieRate: UILabel!
    @IBOutlet weak var movieLanguage: UILabel!
    @IBOutlet weak var movieGenres: UILabel!
    @IBOutlet weak var movieRuntime: UILabel!
    @IBOutlet weak var overView: UILabel!
    
    @IBAction func homePageBtn(_ sender: Any) {
        if movieVM.navigateToWeb(homePageUrl: movieDetail?.homepage) != true {
            print("Home Page Error")
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovieDetail()
    }
    
    func loadMovieDetail() {
        DispatchQueue.global().async {
            self.movieVM.fetchDetailData(id: self.movieId ?? 0) { (data) in
                self.movieDetail = data.first
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.setup()
            }
        }
    }
    
    func setup() {
        movieImage.kf.indicatorType = .activity
        if movie?.backdrop_path != nil {
            movieImage.kf.setImage(with: URL(string: "\(MoviesURL.Domains.Backdrop)" + "\(movie?.backdrop_path ?? "")"))
        } else if movie?.poster_path != nil {
            movieImage.kf.setImage(with: URL(string: "\(MoviesURL.Domains.Poster)" + "\(movie?.poster_path ?? "")"))
        } else {
            movieImage.image = UIImage.init(named: Images.DefaultImage)
        }
        movieTitle.text = movie?.title
        releaseDate.text = "Date: " + movieVM.dateConverter(movie?.release_date ?? "None")
        movieRate.text = "Rate: " + "\(String(describing: movie?.vote_average ?? 0))"
        movieGenres.text = movieGenre
        movieLanguage.text = "Language: " + "\(movie?.original_language?.uppercased() ?? "None")"
        movieRuntime.text = "Runtime: " + "\(String(describing: movieDetail?.runtime ?? 0))" + " mins"
        overView.text = "OverView: " + "\(movie?.overview ?? "None")"
    }
}
