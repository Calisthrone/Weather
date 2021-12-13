//
//  ViewController.swift
//  Weather
//
//  Created by Mohamed Esaa on 10/12/2021.
//

import UIKit
import Alamofire

class PrimaryViewController: UIViewController {
    
    // outlets
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var citiesSegmentedControl: UISegmentedControl!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // query parameters for request
    var parameters = [
        "id" : "360631",
        "appid" : "748863b6cfaa712bf3280f065cb60a3b",
        "units" : "metric"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCityWeatherInfo()
        
        // observe notifications from ChangeCityViewController
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSelectCity), name: NSNotification.Name("User_Did_Select_City"), object: nil)
        
    } // MARK: END OF - viewDidLoad
    

    // describe what happen when user interacts with segment control
    @IBAction func citySelected(_ sender: UISegmentedControl) {
        
        updateParametersWithCityId()

        getCityWeatherInfo()
    }
    
    
    // selector method for incomming notification, update Label and City Id in parameters
    @objc func userDidSelectCity(notification: Notification) {
        
        cityLabel.text = notification.userInfo?["City_Name"] as? String
        
        if let newId = notification.userInfo?["City_Id"] as? String {
            parameters.updateValue(newId, forKey: "id")
        }
        
        getCityWeatherInfo()
    } // userDidSelectCity
    
    
    // set the city Id of the correspondent city. (parameters)
    fileprivate func updateParametersWithCityId() {
        
        switch citiesSegmentedControl.selectedSegmentIndex {
            
        case 0:
            parameters.updateValue("360631", forKey: "id")
            
        case 1:
            parameters.updateValue("108410", forKey: "id")
            
        case 2:
            parameters.updateValue("276781", forKey: "id")
            
        default:
            break
        }
    }
    
    
    // MARK: - getAndDisplayTemperature
    // main request happens here, when a response is received:
    // 1- update city temperature
    fileprivate func getCityWeatherInfo() {
        
        // show activity indicator and start animating
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        AF.request("https://api.openweathermap.org/data/2.5/weather",
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default)
            .responseJSON { response in
                
                // if we can get a result from the response
                if let result = response.value {
                    
                    // if we can cast the response as a NSDictionary
                    if let responseDictionary = result as? NSDictionary {
                        
                        // if we can get the "main" key from the responseDictionary
                        if let mainDictionary = responseDictionary["main"] as? NSDictionary {
                            
                            // this responseDictionary has all the data we are interested in:
                            // 1- Temp
                            // 2- Humidity
                            
                            // if we can get the "temp" key from "main"
                            if let tempAsAny = mainDictionary["temp"] {
                                
                                // cast Any to String
                                let temp = String(describing: tempAsAny)
                                
                                // display the temp on the tempLabel
                                self.tempLabel.text = temp + " °C"
                            }
                            
                            // if we can get the "humidity" key from "main"
                            if let humidityAsAny = mainDictionary["humidity"] {
                                
                                // cast any as string
                                let humidity = String(describing: humidityAsAny)
                                
                                // display the humidity on the humidityLabel
                                self.humidityLabel.text = humidity
                            }
                        }
                    }
                    // hide the activity indicator and stop animating
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
    } // getAndDisplayTemperature
    
} // MARK: END OF - ViewController
