//
//  ViewModel.swift
//  MovieSearch

import UIKit
import Foundation


class MoviesViewModel {
    
    let apiHandler = ApiHandler()
    var movie = [Movie]()
    var movieDetail = [MovieDetail]()
    
    /**
      Fetch movies data, if searchContent is empty, then searching popular movies, otherwise searching by searchContent key word.
    - parameter : searchContent: String , page: Int
    */
    func fetchData(searchContent:String,page:Int, completionHandler: @escaping ([Movie]) -> ()) {
        
        var dataUrl = ""
        if searchContent == "" {
            dataUrl = MoviesURL.PopularUrl + "\(page)"
        } else {
            let replacedContent = searchContent.replacingOccurrences(of: " ", with: "%20")
            dataUrl = MoviesURL.SearchUrl + "\(replacedContent)" + MoviesURL.Domains.Page + "\(page)"
        }
        
        if let data = UserDefaults.standard.value(forKey:dataUrl) as? Data {
            if let userData = try? JSONDecoder().decode(Movie.self, from: data) {
                completionHandler([userData])
            }
        } else {
            apiHandler.getMovieData(urlString: dataUrl) {[weak self] (data:Movie?, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let data = data {
                        self?.movie = [data]
                        UserDefaults.standard.set(try? JSONEncoder().encode(data), forKey:dataUrl)
                    }
                    completionHandler(self?.movie ?? [Movie]())
                }
            }
        }
    }
    
    /**
      Fetch movie detail, runtime and homePage address.
    - parameter : id: Int
    */
    func fetchDetailData(id:Int, completionHandler: @escaping ([MovieDetail]) -> ()) {
        
        let dataUrl = MoviesURL.Domains.BaseUrl + MoviesURL.Domains.Movie + String(id) + MoviesURL.Domains.ApiKey
        
        apiHandler.getMovieData(urlString: dataUrl) {[weak self] (data:MovieDetail?, error) in
            if error != nil {
                print(error!)
            } else {
                if let data = data {
                    self?.movieDetail = [data]
                }
                completionHandler(self?.movieDetail ?? [MovieDetail]())
            }
        }
        
    }
    
    /**
      Navigate movie home page.
    - parameter : homePageUrl: String
    */
    func navigateToWeb(homePageUrl: String?) -> Bool {
        if let url = URL(string: homePageUrl ?? ""),
                UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
            return true
        } else {
            return false
        }
    }
    
    /**
     Read local json file "genresData.json", and return a dictionary of genres
    - returns: [Dictionary]
     # Example #
     ```
      // [28:"Action",12:"Adventure",16"Animation"]
     ```
    */
    func jsonReader(_ jsonfile: String) -> [Int:String]{
        if let path = Bundle.main.path(forResource: jsonfile, ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let genres = jsonResult["genres"] as? [Dictionary<String, Any>] {
                    var genreDictionary = [Int: String]()
                    for genre in genres {
                        let name = genre["name"] as! String
                        let id = genre["id"] as! Int
                        genreDictionary[id] = name
                    }
                    return genreDictionary
                  }
              } catch {
                   print(error.localizedDescription)
              }
        }
        return [:]
    }
    
    /**
     Read local json file "genresData.json", matching id and return a dictionary of genres
    - parameter : dict: [Int: String]
    - returns: genres: [Int]
     # Example #
     ```
     // showGenres([28:"Action",12:"Adventure",16"Animation"],[12,16]){
     //  return "Adventure, Animation"
     //  }
     ```
    */
    func showGenres(_ dict: [Int: String], _ genres: [Int] ) -> String {
        var genresList: String = ""
        for genreId in genres {
            genresList = genresList + (dict[genreId] ?? "") + ", "
        }
        return "Genres: " + genresList.dropLast().dropLast()
    }
    
    /**
     Convert date from "yyyy-MM-dd" format to "MMM dd yyyy"
    - parameter : dateStr: String
    - returns: outputDate: String
     # Example #
     ```
     // dateConverter("2020-01-01"){
     //  return "Jan 1 2020"
     //  }
     ```
    */
    func dateConverter(_ dateStr: String? ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        if let outputDate = dateFormatter.date(from: dateStr ?? "") {
            dateFormatter.dateFormat = "MMM dd yyyy"
            return dateFormatter.string(from: outputDate)
        } else {
            return "None"
        }
    }
    
    
}

