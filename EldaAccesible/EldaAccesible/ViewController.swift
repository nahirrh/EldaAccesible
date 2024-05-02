//
//  ViewController.swift
//  EldaAccesible
//
//  Created by Manager on 2/5/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geoLocate(origin: "Calle Cuba, 2, San Vicente", destination: "Calle Francisco de Quevedo, 46, Elda")
    }
    
    @IBAction func showRouteButton(_ sender: Any) {
    }
    
    func geoLocate(origin: String, destination: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(origin) { placeMarks, error in
            if let myError = error {
                print("Error origin address")
                return
            }
            if let originPlaceMark = placeMarks?.first{
                let originCoordenates = originPlaceMark.location?.coordinate
                
                geocoder.geocodeAddressString(destination) { placeMarks, error in
                    if let myError = error {
                        print ("Erron destination address")
                        return
                    }
                    if let destinationPlaceMark = placeMarks?.first{
                        let destinationCoordenates = destinationPlaceMark.location?.coordinate
                        print(originCoordenates)
                        print(destinationCoordenates)
                    }
                }
            }
        }
    }
}

