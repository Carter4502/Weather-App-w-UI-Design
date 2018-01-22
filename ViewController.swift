//
//  ViewController.swift
//  Weather App
//
//  Created by Carter Belisle on 1/11/18.
//  Copyright © 2018 Carter B. All rights reserved.
//

import UIKit
import CoreLocation
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @IBOutlet var currentDescriptionLabel: UILabel!
    @IBOutlet var currentTempLabel: UILabel!
    @IBOutlet var bgImage: UIImageView!
    @IBOutlet var d1: UILabel!
    @IBOutlet var d2: UILabel!
    @IBOutlet var d3: UILabel!
    @IBOutlet var d4: UILabel!
    @IBOutlet var d5: UILabel!
    @IBOutlet var d6: UILabel!
    @IBOutlet var t1: UILabel!
    @IBOutlet var t2: UILabel!
    @IBOutlet var t3: UILabel!
    @IBOutlet var t4: UILabel!
    @IBOutlet var t5: UILabel!
    @IBOutlet var t6: UILabel!
    @IBOutlet var de1: UILabel!
    @IBOutlet var de2: UILabel!
    @IBOutlet var de3: UILabel!
    @IBOutlet var de4: UILabel!
    @IBOutlet var de5: UILabel!
    @IBOutlet var de6: UILabel!
    @IBOutlet var viewBehindScroll: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewColors: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: Date())
        let hourInt = Int(hour)!
        if (hourInt >= 19) {
            bgImage.image = #imageLiteral(resourceName: "nightFinal")
            scrollViewColors.backgroundColor = UIColor(red:0.32, green:0.26, blue:0.37, alpha:1.0)
            viewBehindScroll.backgroundColor = UIColor(red:0.32, green:0.26, blue:0.37, alpha:1.0)
            scrollView.backgroundColor = UIColor(red:0.32, green:0.26, blue:0.37, alpha:1.0)
        }
        else if (hourInt <= 6) {
            bgImage.image = #imageLiteral(resourceName: "nightFinal")
            scrollViewColors.backgroundColor = UIColor(red:0.32, green:0.26, blue:0.37, alpha:1.0)
            viewBehindScroll.backgroundColor = UIColor(red:0.32, green:0.26, blue:0.37, alpha:1.0)
            scrollView.backgroundColor = UIColor(red:0.32, green:0.26, blue:0.37, alpha:1.0)
        }
        else {
            bgImage.image = #imageLiteral(resourceName: "bgForWeatherApp")
            scrollViewColors.backgroundColor = UIColor(red:0.84, green:0.60, blue:0.35, alpha:1.0)
            viewBehindScroll.backgroundColor = UIColor(red:0.84, green:0.60, blue:0.35, alpha:1.0)
            scrollView.backgroundColor = UIColor(red:0.84, green:0.60, blue:0.35, alpha:1.0)
        }
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func getWeather(location:CLLocation){
        let lati = "\(location.coordinate.latitude)"
        
        let long = "\(location.coordinate.longitude)"
        print(lati,long)

        let jsonUrlString = "http://api.apixu.com/v1/current.json?key=5ba28cbde3964ba8a8241333181301&q=" + lati + "," + long
        guard let url = URL(string: jsonUrlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            
            
            do {
               let dataAsString = (String(data: data, encoding: .utf8))!
                let dictionary = self.convertToDictionary(text: dataAsString)
                let current = dictionary!["current"]!
                let v = current as! NSDictionary
                let temp = v["temp_f"]! as! Double
                let tempRounded = self.round(temp, toNearest: 1)
                let tempFinal = "\(tempRounded)".replacingOccurrences(of: ".0", with: "")
                
                let condition = v["condition"]!
                let textDictionary = condition as! NSDictionary
                let text = "\(textDictionary["text"]!)".capitalized
                DispatchQueue.main.async(execute: {
                    self.currentDescriptionLabel.text = text
                    self.currentTempLabel.text = "\(tempFinal)"
                })
                
                
            }
            
            }.resume()
    }
    var tempsARRAY = [String]()
    var descARRAY = [String]()
    var dayARRAY = [String]()
    func getForecast(location:CLLocation) {
        let lati = "\(location.coordinate.latitude)"
        let long = "\(location.coordinate.longitude)"
        let jsonUrlString = "http://api.apixu.com/v1/forecast.json?key=5ba28cbde3964ba8a8241333181301&q=" + lati + "," + long + "&days=6"
        guard let url = URL(string: jsonUrlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            do {
                let dataAsString = (String(data: data, encoding: .utf8))!
                let dictionary = self.convertToDictionary(text: dataAsString)
                let forecastDic = dictionary!["forecast"]!
                let x = forecastDic as! NSDictionary
                var datesArr = [String]()
                var tempsArr = [String]()
                var descriptionsArr = [String]()
                for item in x {
                    let value = item.value as! NSArray
                    var z = 0
                    while (z<6) {
                        let dateOn = value[z] as! NSDictionary
                        let date1 = dateOn["date"]! as! String
                        let dateFmt = DateFormatter()
                        dateFmt.timeZone = NSTimeZone.default
                        dateFmt.dateFormat =  "yyyy-MM-dd"
                        let date = dateFmt.date(from: date1)
                        let day1 = (date?.dayOfWeek())!
                        datesArr.append(day1)
                        z = z + 1
                    }
                    var l = 0
                    
                    while (l<6) {
                        let dateOn = value[l] as! NSDictionary
                        let day = dateOn["day"]! as! NSDictionary
                        
                        let temp = day["avgtemp_f"]! as! Double
                        let tempRounded = "\(self.round(temp, toNearest: 1))"
                        let tempFinal = tempRounded.replacingOccurrences(of: ".0", with: "")
                        tempsArr.append(tempFinal)
                        let condition = day["condition"]! as! NSDictionary
                        let descriptionOfDay = condition["text"]!
                        if ("\(descriptionOfDay)".range(of: "rain") != nil) {
                            let final = "Rain"
                            descriptionsArr.append(final)
                            l = l + 1
                        }
                        else if ("\(descriptionOfDay)".range(of: "snow") != nil) {
                            let string = "Snow"
                            descriptionsArr.append(string)
                            l = l + 1
                        }
                        else {
                            descriptionsArr.append("\(descriptionOfDay)")
                            l = l + 1
                        }
                    }
              
                }
                DispatchQueue.main.async(execute: {
                   self.d1.text = "Today"
                    self.d2.text = datesArr[1]
                    self.d3.text = datesArr[2]
                    self.d4.text = datesArr[3]
                    self.d5.text = datesArr[4]
                    self.d6.text = datesArr[5]
                    self.de1.text = descriptionsArr[0]
                    self.de2.text = descriptionsArr[1]
                    self.de3.text = descriptionsArr[2]
                    self.de4.text = descriptionsArr[3]
                    self.de5.text = descriptionsArr[4]
                    self.de6.text = descriptionsArr[5]
                    self.t1.text = tempsArr[0] + "°"
                    self.t2.text = tempsArr[1] + "°"
                    self.t3.text = tempsArr[2] + "°"
                    self.t4.text = tempsArr[3] + "°"
                    self.t5.text = tempsArr[4] + "°"
                    self.t6.text = tempsArr[5] + "°"
                    
                
                })
                
                
            }
            
            }.resume()
        print(descARRAY)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getWeather(location: location)
            getForecast(location: location)
            self.locationManager.delegate = nil
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
        showLocationDisabledPopUp()
        }
    }
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Services access disabled, please enable in settings.", message: "We need your location to tell you the weather!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }
}

