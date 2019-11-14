//
//  CityViewController.swift
//  AppPogodowa
//
//  Created by Lukasz Stawowy on 11/10/19.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    var woeId: String!
    var weatherType: String!
    
    @IBOutlet weak var CellImage: UIImageView!
    @IBOutlet weak var CityName: UILabel!
    @IBOutlet weak var Temperature: UITextView!
}

class CityTableViewController: UITableViewController {
    
    var cityPressed:String!
    var cityPressedWoeId:String!
    var cityToAdd: City?
    var cities = [City]()
    
    @IBOutlet weak var CurrentDate: UILabel!
    @IBOutlet var CityTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentShortDate()
        loadSampleCities()
    }
    
    func getCurrentShortDate() -> Void {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        CurrentDate.text = dateFormatter.string(from: currentDate as Date) + " "
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
        cell.woeId = city.weId
        cell.weatherType = city.currentWeatherType
        
        let urlString = "https://www.metaweather.com/static/img/weather/png/\(city.currentWeatherType).png"
        cell.CellImage.downloaded(from: urlString)

        cell.Temperature.text = city.temp
        
        return cell
    }
    
    private func loadSampleCities() {
        addCity(cityName: "Warsaw", woeId: "523920")
        addCity(cityName: "London", woeId: "44418")
        addCity(cityName: "Moscow", woeId: "2122265")
    }
    
    func addCity(cityName: String,woeId: String) -> Void {
        var tempURL = URL(string: "https://www.metaweather.com/api/location/\(woeId)/")!
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: tempURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            do {
                var weather = try JSONSerialization.jsonObject(with:data!) as? ([String : Any])
                if (weather == nil) {
                    
                } else {
                    var consolidatedWeather = weather!["consolidated_weather"]! as? [Any]
                    let weatherDay = consolidatedWeather![0] as? ([String : Any])
                    var temperature = "\(weatherDay!["the_temp"]!)"
                    var weatherState = "\(weatherDay!["weather_state_abbr"]!)"
                    let city = City(name: cityName, weId: woeId, temp: temperature, currentWeatherType: weatherState)
                    self.cities += [city]
                    self.CityTableView.reloadData()
                }
            } catch {
                print("Serialization failed")
            }
        })
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "cityChooseSegue") {
            var viewController = segue.destination as! WeatherViewController
            let cityCell = sender.unsafelyUnwrapped as! CityTableViewCell
            viewController.cityPressed = cityCell.CityName.text!
            viewController.weatherURL = URL(string: "https://www.metaweather.com/api/location/\(cityCell.woeId!)/")!
        }
        if (segue.identifier == "cityAddSegue") {
            var cityController = segue.destination as! CityTableViewController
            let cityCell = sender.unsafelyUnwrapped as! SearchTableViewCell
            let city = City(name: cityCell.CityName.text!, weId: cityCell.woeId!, temp: cityCell.Temperature.text!, currentWeatherType: cityCell.weatherType)
            cityController.cities.append(city)
            cityController.CityTableView.reloadData()
        }
    }
    
}

struct City {
    var name = ""
    var weId = ""
    var temp = ""
    var currentWeatherType = ""
}
