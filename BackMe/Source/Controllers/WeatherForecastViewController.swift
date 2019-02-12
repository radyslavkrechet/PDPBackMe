//
//  WeatherForecastViewController.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/14/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit

class WeatherForecastViewController: UIViewController {
    @IBOutlet var forecastLabel: UILabel!

    private var forecast: Int {
        return UserDefaults.standard.integer(forKey: "forecast")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        forecastLabel.text = String(forecast)
    }

    // MARK: - Configuration

    func loadForecast() {
        NetworkService.forecast { [unowned self] forecast in
            guard let forecast = forecast else {
                return
            }

            self.setForecast(forecast)
            self.forecastLabel.text = String(forecast)
        }
    }

    private func setForecast(_ forecast: Int) {
        UserDefaults.standard.set(forecast, forKey: "forecast")
    }
    
    // MARK: - Actions
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        loadForecast()
    }
}
