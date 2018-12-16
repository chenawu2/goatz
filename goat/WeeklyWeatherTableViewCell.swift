//
//  WeeklyWeatherTableViewCell.swift
//  goat
//
//  Created by Chen Wu on 12/15/18.
//  Copyright © 2018 Chen Wu. All rights reserved.
//

import Foundation
import UIKit

final class WeeklyWeatherTableViewCell: UITableViewCell {
    static let identifier = "weeklyWeatherTableViewCell"
    
    @IBOutlet var iconImageView: UIImageView?
    @IBOutlet var forecastLabel: UILabel?
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEEEE"
        return formatter
    }()
    
    func setup(dailyWeather: DailyWeather) {
        self.iconImageView?.image = UIImage(imageLiteralResourceName: dailyWeather.iconImageName)
        let date = Date(timeIntervalSince1970: dailyWeather.time)
        let dayOfWeek = formatter.string(from: date)
        let tempString = "\(dayOfWeek) H:\(dailyWeather.minTemp) L:\(dailyWeather.maxTemp)"
        self.forecastLabel?.text = tempString
    }
}
