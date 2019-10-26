//
//  ViewController.swift
//  AppPogodowa
//
//  Created by Guest User on 17.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let weatherHylp = WeatherHelper.init()
        weatherHylp.load()
    }


}

func something () -> Void {
    return
}

class WeatherHelper {
    static let weatherURL = URL(string: "https://www.metaweather.com/api/location/44418/")!
    
    func load() -> Void {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: WeatherHelper.weatherURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            let resultData = data!
            do {
                let serializedData = try JSONSerialization.jsonObject(with:resultData)
                print(serializedData)
            } catch {
                print("Serialization failed")
            }
            
        })
        task.resume()

        return
    }
    
    
    
    func getCurrentShortDate() -> String {
        let todaysDate = NSDate().dateFromString(date: "2015-02-04 23:29:28", format:  "yyyy-MM-dd HH:mm:ss")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let DateInFormat = dateFormatter.string(from: todaysDate as Date)
        
        return DateInFormat
    }
    
}

extension NSDate {
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = DateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale as Locale
        formatter.dateFormat = format
        
        return formatter.date(from: date)! as NSDate
    }
}
