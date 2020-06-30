//
//  ApiHandler.swift
//  MovieSearch

import Foundation
class ApiHandler {
    
    /**
     Api request setup
    */
    func getMovieData<T: Codable>(urlString:String, completionHandler: @escaping(T?,Error?)->()){
        guard let url = URL(string: urlString) else {return}
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        urlSession.dataTask(with: url) { (data, resp, error) in
            let response = resp as! HTTPURLResponse
            if response.statusCode == 200 && error == nil{
                do {
                    let userData = try JSONDecoder().decode(T.self, from: data!)
                    completionHandler(userData,nil)
                } catch {
                    completionHandler(nil,error)
                }
            } else {
                print("resp error")
                completionHandler(nil,error)
            }
        }.resume()
    }
}

