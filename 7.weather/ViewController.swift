//
//  ViewController.swift
//  7.weather
//
//  Created by JIHA on 2022/05/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var weatherStackView: UIStackView!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func showAlert(errorMessage: String) {
        let alert = UIAlertController(title: "에러", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description
        }
        self.temperatureLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃"
        self.minTemperatureLabel.text = "최저: \(Int(weatherInformation.temp.tempMin - 273.15))℃"
        self.maxTemperatureLabel.text = "최대: \(Int(weatherInformation.temp.tempMax - 273.15))℃"
    }

    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
    
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=e87030286b1c3f117a94760cdd449a62") else {return}
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { [weak self] data, respons, error in
            let successRange = (200..<300)
            guard let data = data, error == nil else {return}
            let decoder = JSONDecoder()
            if let respons = respons as? HTTPURLResponse, successRange.contains(respons.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else {return}
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else {return}
                DispatchQueue.main.async {
                    self?.showAlert(errorMessage: errorMessage.message)
                }
            }

        }.resume()
    }
}

