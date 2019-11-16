//
//  ViewController.swift
//  AppPogodowa
//
//  Created by Guest User on 17.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {  // for
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

class WeatherViewController: UIViewController {

    var cityPressed = "London"
    let regionRadius: CLLocationDistance = 100000
    
    var lattitude: Double = 1.1
    var longitude: Double = 1.1
    var initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    var currentPage:Int = 0
    var lastPage:Int = 0
    var weatherURL = URL(string: "https://www.metaweather.com/api/location/44418/")!
    var weatherData:([String:Any])? = nil
    var consolidatedWeatherList:[Any]? = nil
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var WeatherType: UITextView!
    @IBOutlet weak var TempMin: UITextView!
    @IBOutlet weak var TempMax: UITextView!
    @IBOutlet weak var WindDirection: UITextView!
    @IBOutlet weak var WindSpeed: UITextView!
    @IBOutlet weak var Precipitation: UITextView!
    @IBOutlet weak var Pressure: UITextView!
    @IBOutlet weak var Image: UIImageView!
    
    @IBOutlet weak var PreviousButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    
    @IBOutlet weak var CurrentPage: UITextView!
    @IBOutlet weak var LastPage: UITextView!
    @IBOutlet weak var MapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityName.text = cityPressed
        self.PreviousButton.isEnabled = false
        self.NextButton.isEnabled = false
        load()
        centerMapOnLocation(location: self.initialLocation)
        self.CurrentPage.text = "\(self.currentPage)"
        self.LastPage.text = "\(self.lastPage)"
    }
    
    func centerMapOnLocation(location: CLLocation) {
        initialLocation = CLLocation(latitude: self.lattitude, longitude: self.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        MapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: self.lattitude, longitude: self.longitude)
        MapView.addAnnotation(annotation)
    }
    
    func checkButtons() -> Void {
        self.CurrentPage.text = "\(self.currentPage)"
        if(currentPage > 0){
            PreviousButton.isEnabled = true
        } else {
            PreviousButton.isEnabled = false
        }
        
        if(currentPage < lastPage){
            NextButton.isEnabled = true
        } else {
            NextButton.isEnabled = false
        }
    }
    
    @IBAction func previousButton(_ sender: Any) {
        if (currentPage > 0) {
            currentPage = currentPage-1
        }
        checkButtons()
        self.updateFields()
    }
    
    @IBAction func nextButton(_ sender: Any) {
        if (currentPage < lastPage) {
            currentPage = currentPage+1
        }
        checkButtons()
        self.updateFields()
    }
    
    func load() -> Void {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: weatherURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            do {
                self.weatherData = try JSONSerialization.jsonObject(with:data!) as? ([String : Any])
                if (self.weatherData == nil){
                    
                } else {
                    self.consolidatedWeatherList = self.weatherData!["consolidated_weather"]! as? [Any]
                    self.lastPage = (self.consolidatedWeatherList?.count)!-1
                    self.LastPage.text = "\(self.lastPage)"
                    self.updateFields()
                    self.checkButtons()
                }
            } catch {
                print("Serialization failed")
            }
        })
        task.resume()
    }
    
    func updateFields() -> Void {
        print(self.consolidatedWeatherList!)
        let weatherDay = self.consolidatedWeatherList![currentPage] as? ([String : Any])
        
        WeatherType.text=weatherDay!["weather_state_name"]! as! String
        
        let min_temp = weatherDay!["min_temp"]! as! Double
        TempMin.text="\(min_temp.rounded(toPlaces: 3)) °C"
        
        let max_temp = weatherDay!["max_temp"]! as! Double
        TempMax.text="\(max_temp.rounded(toPlaces: 3)) °C"

        WindDirection.text="\(weatherDay!["wind_direction_compass"]!)"
        
        let wind_speed = weatherDay!["wind_speed"]! as! Double
        WindSpeed.text="\(wind_speed.rounded(toPlaces: 3)) km/h"
        
        Precipitation.text="\(weatherDay!["humidity"]!) %"
        
        Pressure.text="\(weatherDay!["air_pressure"]!) hPa"
        
        let urlString = "https://www.metaweather.com/static/img/weather/png/\(weatherDay!["weather_state_abbr"]!).png"
        print(urlString)
        self.Image.downloaded(from: urlString)
    }
}
