//
//  CitySearchViewController.swift
//  AppPogodowa
//
//  Created by Lukasz Stawowy on 11/10/19.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit
import CoreLocation

extension CLPlacemark {
    var compactAddress: String? {
        if name != nil {
            var result = "Aktualna pozycja : "
            if let city = locality {
                result += "\(city)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
        }
        return "Fail"
    }
}

class CitySearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var CitySearchTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        self.getLocationName()
        super.viewDidLoad()
        CitySearchTableView.dataSource = self
        CitySearchTableView.delegate = self
    }
    
    var searchData: [Any]? = nil
    var cities = [City]()
    var searchURL = URL(string: "https://www.metaweather.com/api/location/search/?query=Moscow")!
    
    @IBAction func cancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        self.load()
    }
    
    @IBAction func searchLocationButton(_ sender: Any) {
        self.loadLocation()
    }
    
    @IBOutlet weak var CurrentLocation: UITextView!
    
    func getLocation() -> String {
        var locationManager = CLLocationManager()
        var currentLocation: CLLocation!  = locationManager.location

        return "\(currentLocation.coordinate.longitude),\(currentLocation.coordinate.latitude)"
    }
    
    func getLocationName() -> Void {
        var locationManager = CLLocationManager()
        var currentLocation: CLLocation! = locationManager.location
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) {
            (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            self.CurrentLocation.text = "Unable to Find Address for Location"
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                self.CurrentLocation.text = placemark.compactAddress
            } else {
                self.CurrentLocation.text = "No Matching Addresses Found"
            }
        }
    }
    
    func loadLocation() -> Void {
        let location = getLocation()
        self.searchURL = URL(string: "https://www.metaweather.com/api/location/search/?lattlong=\(location)")!
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: searchURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in do {
            self.searchData = try JSONSerialization.jsonObject(with:data!) as? [Any]
            while (self.searchData! == nil){}
            for cityDict in self.searchData! {
                if let dict = cityDict as? [String: Any] {
                    let cityName = "\(dict["title"]!)"
                    let woeId = "\(dict["woeid"]!)"
                    self.addCity(cityName: cityName, woeId: woeId)
                }
            }
        } catch {
            print("Serialization failed")
            }
        })
        task.resume()
    }
    
    func load() -> Void {
        self.searchURL = URL(string: "https://www.metaweather.com/api/location/search/?query=\(self.searchField.text!)")!
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: searchURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in do {
                self.searchData = try JSONSerialization.jsonObject(with:data!) as? [Any]
                while (self.searchData! == nil){}
                for cityDict in self.searchData! {
                    if let dict = cityDict as? [String: Any] {
                        let cityName = "\(dict["title"]!)"
                        let woeId = "\(dict["woeid"]!)"
                        self.addCity(cityName: cityName, woeId: woeId)
                    }
                }
            } catch {
                print("Serialization failed")
            }
        })
        task.resume()
    }
    
    func addCity(cityName: String,woeId: String) -> Void {
        let tempURL = URL(string: "https://www.metaweather.com/api/location/\(woeId)/")!
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: tempURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            do {
                var weather = try JSONSerialization.jsonObject(with:data!) as? ([String : Any])
                if (weather == nil) {
                    
                } else {
                    var latt_long = weather!["latt_long"]! as? String
                    var consolidatedWeather = weather!["consolidated_weather"]! as? [Any]
                    let weatherDay = consolidatedWeather![0] as? ([String : Any])
                    let temperature = "\(weatherDay!["the_temp"]!)"
                    let weatherState = "\(weatherDay!["weather_state_abbr"]!)"
                    let city = City(name: cityName, weId: woeId, temp: temperature, currentWeatherType: weatherState, lattitude_longitude: latt_long!)
                    self.cities += [city]
                    self.CitySearchTableView.reloadData()
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
        let cellIdentifier = "SearchCityCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SearchCellId.")
        }
        
        let city = cities[indexPath.row]
        
        cell.CityName.text = city.name
        cell.woeId = city.weId
        cell.weatherType = city.currentWeatherType
        
        let urlString = "https://www.metaweather.com/static/img/weather/png/\(city.currentWeatherType).png"
        cell.CellImage.downloaded(from: urlString)
        
        cell.Temperature.text = city.temp + " °C"
        cell.latt_long = city.lattitude_longitude
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "cityAddSegue") {
            let cityController = segue.destination as! CityTableViewController
            let cityCell = sender.unsafelyUnwrapped as! SearchTableViewCell
            let city = City(name: cityCell.CityName.text!, weId: cityCell.woeId!, temp: cityCell.Temperature.text!, currentWeatherType: cityCell.weatherType, lattitude_longitude: cityCell.latt_long)
            cityController.cities += [city]
        }
    }
    
}

class SearchTableViewCell: UITableViewCell {
    var woeId: String!
    var weatherType: String!
    var latt_long: String!
    
    @IBOutlet weak var CellImage: UIImageView!
    @IBOutlet weak var CityName: UILabel!
    @IBOutlet weak var Temperature: UITextView!
}
