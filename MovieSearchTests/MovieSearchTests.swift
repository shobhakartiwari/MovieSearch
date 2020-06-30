//
//  MovieSearchTests.swift
//  MovieSearchTests

import XCTest
@testable import MovieSearch

class MovieSearchTests: XCTestCase {

    var detailvc: MovieSearch.DetailsViewController!
    var apiHandler: ApiHandler!
    var viewModel = MoviesViewModel()
    var movieTest = [Results]()
    let url =  MoviesURL.PopularUrl
    
    func setUpViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.detailvc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? MovieSearch.DetailsViewController
        self.detailvc.loadView()
        self.detailvc.viewDidLoad()
    }
    
    override func setUp() {
        setUpViewControllers()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testApi() {
        let fileUrl = URL(string: url)!
        let expectation = XCTestExpectation(description: "testApi")
        let dataTask = URLSession.shared.dataTask(with: fileUrl) { (data, _, _) in
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        dataTask.resume()
        wait(for: [expectation], timeout: 2)
    }
    
    func testJsonReader() {
        var jsonData = viewModel.jsonReader("genresData")
        XCTAssertEqual(jsonData[12],"Adventure")
        XCTAssertEqual(jsonData[16],"Animation")
        jsonData = viewModel.jsonReader("emptyData")
        XCTAssertEqual(jsonData[12],nil)
        
    }
    
    func testShowGenres() {
        let genres = viewModel.showGenres([1:"Action",2:"Adventure",3:"Animation",40:"Comedy"], [40,1])
        XCTAssertEqual(genres,"Genres: Comedy, Action")
    }
    
    func testfetchData() {
        let expectation = XCTestExpectation(description: "fetchData")
        viewModel.fetchData(searchContent: "I am",page: 5) { (data) in
            self.movieTest = data.first?.results ?? [Results]()
            XCTAssertNotNil(self.movieTest)
            XCTAssertEqual(self.movieTest.first?.id,99478)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
        
    }
    
    func testfetchDetailData() {
        let expectation = XCTestExpectation(description: "fetchData")
        viewModel.fetchDetailData(id:6479) { (data) in
            XCTAssertNotNil(data.first?.id)
            XCTAssertEqual(data.first?.id,6479)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
        
        let expectationn = XCTestExpectation(description: "fetchNilData")
        viewModel.fetchDetailData(id:000000000) { (data) in
            XCTAssertEqual(self.movieTest.first?.id,nil)
            expectationn.fulfill()
        }
        wait(for: [expectationn], timeout: 2)
        
    }
    
    func testDetailVC() {
        XCTAssertNotNil(self.detailvc, "VC is nil")
    }
    
    func testnavigateToWeb() {
        var canOpen = viewModel.navigateToWeb(homePageUrl: "https://www.apple.com")
        XCTAssertEqual(canOpen,true)
        canOpen = viewModel.navigateToWeb(homePageUrl: "apple")
        XCTAssertEqual(canOpen,false)
    }
    
    func testDateConverter() {
        var date = viewModel.dateConverter("1988-11-29")
        XCTAssertEqual(date,"Nov 29 1988")
        date = viewModel.dateConverter("")
        XCTAssertEqual(date,"None")
    }
    
    func testConstant() {
        var newUrl = MoviesURL.Domains.BaseUrl + MoviesURL.PopularUrl
        var target = "https://api.themoviedb.org/3https://api.themoviedb.org/3/movie/popular?api_key=ff40f379903bb37fc9d705201638bef1&page="
        XCTAssertEqual(newUrl,target)
        newUrl = Images.BackGroundImage + Images.DefaultImage
        target = "lunch-backgrounddefault-movie"
        XCTAssertEqual(newUrl,target)
    }
}
