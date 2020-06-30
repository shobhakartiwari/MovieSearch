//
//  ViewController.swift
//  MovieSearch


import UIKit
import Kingfisher
import ProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let movieVM = MoviesViewModel()
    var movieInfo = [Results]()
    var genresDict = [Int:String]()
    var isSearching = false
    var searchingContent = ""
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup("",pageNumber)
    }
    
    /**
     Controlling spinner and fetching movies data
    */
    func setup(_ str: String,_ page: Int) {
        genresDict = movieVM.jsonReader(JsonFile.GenresJsonFile)
        ProgressHUD.show("Loading......")
        DispatchQueue.global().async {
            self.movieVM.fetchData(searchContent: str,page: page) { (data) in
                self.movieInfo = self.movieInfo + (data.first?.results ?? [Results]())
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            }
        }
    }
    
    /**
    At the end of tableView and continually scroll，will increase the height of tableview and load next page movies .
    */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let contentSize = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offset > contentSize - frameHeight {
            pageNumber += 1
            if isSearching {
                setup(searchingContent,pageNumber)
            } else {
                setup("",pageNumber)
            }
            
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    /**
    Search movie
    */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        movieInfo = []
        pageNumber = 1
        if searchBar.text == "" && isSearching == true {
            isSearching = false
            setup("",pageNumber)
        } else if searchBar.text != ""{
            searchingContent = searchBar.text ?? ""
            isSearching = true
            setup(searchBar.text ?? "",pageNumber)
        }
    }
    
    /**
    Scroll top
    */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.setContentOffset(.zero, animated: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        self.searchBar.showsCancelButton = false
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    /**
    Table view
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomePageCell
        cell.movieTitle.text = movieInfo[indexPath.row].title
        cell.movieDate.text = movieVM.dateConverter(movieInfo[indexPath.row].release_date)
        cell.movieGenre.text = movieVM.showGenres(genresDict,movieInfo[indexPath.row].genre_ids ?? [0])
        cell.movieRate.text = "Rate: " + "\(String(describing: movieInfo[indexPath.row].vote_average ?? 0))"
        cell.movieImage.kf.indicatorType = .activity
        if movieInfo[indexPath.row].poster_path != nil {
            cell.movieImage.kf.setImage(with: URL(string: "\(MoviesURL.Domains.Poster)" + "\(movieInfo[indexPath.row].poster_path ?? "")"))
        } else {
            cell.movieImage.image = UIImage.init(named: Images.DefaultImage)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        vc.movieGenre = (tableView.cellForRow(at: indexPath) as! HomePageCell).movieGenre.text
        vc.movie = movieInfo[indexPath.row]
        vc.movieId = movieInfo[indexPath.row].id
        self.present(vc, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
