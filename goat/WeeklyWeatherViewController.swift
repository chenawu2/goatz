//
//  WeeklyWeatherViewController.swift
//  goat
//
//  Created by Chen Wu on 12/15/18.
//  Copyright © 2018 Chen Wu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

final class WeeklyWeatherViewController: UIViewController {
    @IBOutlet var tableView: UITableView?
    
    var locationStore: LocationStore?
    var weatherStore: WeatherStore?
    
    private var weatherResponse: WeatherResponse?
    private var observation: NSKeyValueObservation?
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "request to see weather"
        self.tableView?.tableFooterView = UIView()
        self.observation = locationStore?.observe(\LocationStore.location, options: [.new], changeHandler: { [weak self] (store, change) in
            guard let location = change.newValue as? CLLocation else { return }
            self?.locationDidChange(location: location)
        })
    }
    
    private func locationDidChange(location: CLLocation) {
        self.weatherStore?.requestWeather(location: location, completionHandler: { (response) in
            self.activityIndicatorView.stopAnimating()
            switch response {
            case .success(let weatherResponse):
                self.navigationItem.title = weatherResponse.timezone
                self.weatherResponse = weatherResponse
                self.tableView?.reloadData()
            case .failure(_):
                break
            }
        })
    }
    
    @IBAction func askUserForPermission(_ sender: Any) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.locationStore?.requestUserPermission(completionHandler: { (response) in
            switch response {
            case .success:
                self.activityIndicatorView.startAnimating()
            case .failure:
                self.presentFailureAlert()
            }
        })
    }
    
    private func presentFailureAlert() {
        let alert = UIAlertController(title: "Failure", message: "You must allow location permission to see the weather", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension WeeklyWeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherResponse?.dailyWeather.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = WeeklyWeatherTableViewCell.identifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? WeeklyWeatherTableViewCell,
            let dailyWeather = self.weatherResponse?.dailyWeather[safe: indexPath.row] else { fatalError() }
        cell.setup(dailyWeather: dailyWeather)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let dailyWeather = self.weatherResponse?.dailyWeather[safe: indexPath.row],
        let dailyWeatherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DailyWeatherSummaryViewController") as? DailyWeatherSummaryViewController
            else { fatalError() }
        dailyWeatherVC.dailyWeather = dailyWeather
        self.navigationController?.pushViewController(dailyWeatherVC, animated: true)
    }
}

fileprivate extension Collection {
    subscript (safe index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
