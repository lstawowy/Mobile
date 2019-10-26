//
//  Weather.swift
//  AppPogodowa
//
//  Created by Guest User on 24.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import Foundation

struct WeatherResponse:Decodable {
    let consolidated_weather: [ConsolidatedWeather]?
    let time: Date?
    let title: String?
    let location_type: String?
    let latt_long: String?
    let timezone: String?
}

struct ConsolidatedWeather:Decodable {
    let id:Int
    let wearher_state_name: String
    let min_temp:Double
    let max_temp:Double
    let the_temp:Double
    let applicable_date: Date
    let wind_speed: Double
    let wind_direction: Double
    let air_pressure: Double
    let humidity: Double
    let visibility: Double
    let predictability: Int
}
