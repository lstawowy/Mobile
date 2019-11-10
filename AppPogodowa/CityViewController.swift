//
//  CityViewController.swift
//  AppPogodowa
//
//  Created by Lukasz Stawowy on 11/10/19.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var CellImage: UIImageView!
    
    @IBOutlet weak var CityName: UILabel!
    
    @IBOutlet weak var Temperature: UITextView!
}


//    func getCurrentShortDate() -> Void {
//        let currentDate = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        CurrentDate.text = dateFormatter.string(from: currentDate as Date)
//    }

class CityTableViewController: UITableViewController {
    var cities = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleCities()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CityTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CityTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CityTableViewCell.")
        }

        let city = cities[indexPath.row]

        cell.CityName.text = city.name

        let urlString = "https://www.metaweather.com/static/img/weather/png/\(city.currentWeatherType).png"
        print(urlString)
        cell.CellImage.downloaded(from: urlString)

        cell.Temperature.text = city.temp
        
        return cell
    }
    
    
    
    private func loadSampleCities() {
        let city1 = City(name: "Warsaw", weId: "523920", temp: "5", currentWeatherType: "hr")
        
        let city2 = City(name: "London", weId: "44418", temp: "6", currentWeatherType: "hr")

        let city3 = City(name: "Moscow", weId: "2122265", temp: "7", currentWeatherType: "hr")

        cities += [city1, city2, city3]
    }
}


struct City {
    var name = ""
    var weId = ""
    var temp = ""
    var currentWeatherType = ""
}
