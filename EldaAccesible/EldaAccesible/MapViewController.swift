import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var showRouteButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setStyles()
        
//      Center Location in Elda
        let eldaLocation = CLLocation(latitude: 38.4778306, longitude: -0.7998126)
        mapView.centerToLocation(eldaLocation)
        
//      Set Elda map bounderies
        let coordinateRegion = MKCoordinateRegion(center: eldaLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: coordinateRegion), animated: true)
        
//      Set max zoom range to Elda map
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 10000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        mapView.delegate = self
    }
    
    private func setStyles(){
        setStyles(for: originTextField)
        setStyles(for: destinationTextField)
        setButtonsStyles(for: profileButton)
        setButtonsStyles(for: showRouteButton)
    }
    
    private func setStyles(for textField: UITextField) {
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowOpacity = 0.7
        textField.layer.shadowRadius = 10
    }
    
    private func setButtonsStyles(for button: UIButton) {
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.7
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
            if let originPlaceMark = placeMarks?.first {
                let originCoordenates = originPlaceMark.location?.coordinate
                
                geocoder.geocodeAddressString(destination) { placeMarks, error in
                    if let myError = error {
                        print ("Erron destination address")
                        return
                    }
                    if let destinationPlaceMark = placeMarks?.first {
                        let destinationCoordenates = destinationPlaceMark.location?.coordinate
                        if self.isElda(coordenates: originCoordenates!) && self.isElda(coordenates: destinationCoordenates!){
                            self.showRoute(originCoordenate: originCoordenates!, destinationCoordenates: destinationCoordenates!)
                        }
                        else {
                            self.showAlert()
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Error", message: "La ruta debe ser en Elda", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
//  Check if coordeantes are in Elda or not
    func isElda(coordenates: CLLocationCoordinate2D) -> Bool {
        let topLimitLongitude = -0.8050361294642698
        let topLimitLatitude = 38.490657721389795
        let bottomLimitLongitude = -0.7824278387625156
        let bottomLimitLatitude = 38.45913775904208
        
        if coordenates.latitude > topLimitLatitude || coordenates.latitude < bottomLimitLatitude || coordenates.longitude > bottomLimitLongitude || coordenates.longitude < topLimitLongitude{
            return false
        }
            
        
        return true
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

extension MapViewController: MKMapViewDelegate{
    
//  Set renderer parameters to style route
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5.0
        return renderer
    }
}

extension MKMapView{
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

