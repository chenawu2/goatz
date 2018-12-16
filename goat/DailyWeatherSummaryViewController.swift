//
//  DailyWeatherSummaryViewController.swift
//  goat
//
//  Created by Chen Wu on 12/15/18.
//  Copyright © 2018 Chen Wu. All rights reserved.
//

import Foundation
import UIKit

final class DailyWeatherSummaryViewController: UIViewController {
    @IBOutlet var summaryLabel: UILabel?
    
    var dailyWeather: DailyWeather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.summaryLabel?.text = self.dailyWeather?.summary
    }
}
