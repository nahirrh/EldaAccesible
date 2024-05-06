import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
//      Center Location in Elda
        let eldaLocation = CLLocation(latitude: 38.4778306, longitude: -0.7998126)
        mapView.centerToLocation(eldaLocation)
        
//      Set Elda map bounderies
        let coordinateRegion = MKCoordinateRegion(center: eldaLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: coordinateRegion), animated: true)
        
//      Set max zoom range to Elda map
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 10000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        mapView.delegate = self
    }
    
    @IBAction func showRouteButton(_ sender: Any) {
        geoLocate(origin: originTextField.text!, destination: destinationTextField.text!)
    }
    
//  Transform user parameters (origin and destination) to coordenates
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
                        
                        self.showRoute(originCoordenate: originCoordenates!, destinationCoordenates: destinationCoordenates!)
                    }
                }
            }
        }
    }
//  Drow route
    func showRoute(originCoordenate: CLLocationCoordinate2D, destinationCoordenates: CLLocationCoordinate2D){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: originCoordenate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordenates))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            guard let response = response else {return}
            
            if let route = response.routes.first{
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
        }
    }
}
//  MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate{
    
//  Set renderer parameters to style route
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5.0
        return renderer
    }
}

extension MKMapView{
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 500) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

