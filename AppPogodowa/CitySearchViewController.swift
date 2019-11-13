//
//  CitySearchViewController.swift
//  AppPogodowa
//
//  Created by Lukasz Stawowy on 11/10/19.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class CitySearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var CitySearchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CitySearchTableView.dataSource = self
        CitySearchTableView.delegate = self
    }
    
    var searchData: [Any]? = nil
    var cities = [City]()
    var searchURL = URL(string: "https://www.metaweather.com/api/location/search/?query=Moscow")!
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchTable: UITableView!
    
    @IBAction func cancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        self.load()
    }

    func load() -> Void {
        self.searchURL = URL(string: "https://www.metaweather.com/api/location/search/?query=\(self.searchField.text)")!
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: searchURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in do {
                self.searchData = try JSONSerialization.jsonObject(with:data!) as? [Any]
                while (self.searchData! == nil){}
                for cityDict in self.searchData! {
                    if let dict = cityDict as? [String: Any] {
                        var city = City(name: "", weId: "", temp: "", currentWeatherType: "")
                        city.weId = "\(dict["woeid"]!)"
                        city.name = "\(dict["title"]!)"
                        city.temp = WeatherViewController.getCurrentTemp(woeId: city.weId)
                        self.cities.append(city)
                    }
                }
            } catch {
                print("Serialization failed")
            }
        })
        task.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchCellId"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CityTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SearchCellId.")
        }
        
        let city = cities[indexPath.row]
        
        cell.CityName.text = city.name
        cell.woeId = city.weId
        cell.weatherType = city.currentWeatherType
        
        let urlString = "https://www.metaweather.com/static/img/weather/png/\(city.currentWeatherType).png"
        cell.CellImage.downloaded(from: urlString)
        
        cell.Temperature.text = city.temp
        
        return cell
    }
    
}

class SearchTableViewCell: UITableViewCell {
    var woeId: String!
    var weatherType: String!
    
    @IBOutlet weak var CellImage: UIImageView!
    @IBOutlet weak var CityName: UILabel!
    @IBOutlet weak var Temperature: UITextView!
}
