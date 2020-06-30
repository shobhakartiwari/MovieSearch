//
//  Movies.swift
//  MovieSearch


import Foundation

struct Movie:Codable{
    
    let page: Int?
    let total_results: Int?
    let total_pages: Int?
    let results: [Results]?

}

struct Results: Codable {
    
    let vote_count: Int?
    let video: Bool?
    let poster_path: String?
    let id: Int?
    let adult: Bool?
    let backdrop_path: String?
    let original_language: String?
    let original_title: String?
    let genre_ids: [Int]?
    let title: String?
    let vote_average: Float?
    let overview: String?
    let release_date: String?
    
}


