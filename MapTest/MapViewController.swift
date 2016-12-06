//
//  ViewController.swift
//  MapTest
//
//  Created by yoho chen on 10/19/16.
//  Copyright © 2016 Yoho. All rights reserved.
//

import UIKit
import MapKit
import Darwin
import Firebase
import FirebaseDatabase

struct Intersect
{
    /*
     Checks whether a given parking zone is within the circular region
     */
    func check(location: CLLocationCoordinate2D, line: MapLine, radius: Double) -> Bool
    {
        //conversion units
        let mileConversion = 69.11
        let cosineConversion = 57.3
        
        //instantiates a vector representing the parking zone
        let lineVector = [(line.coor2.latitude - line.coor1.latitude) * mileConversion, (line.coor2.longitude - line.coor1.longitude) * mileConversion * cos(line.coor1.latitude/cosineConversion)]
        
        //instantiates a vector representing the user's location to one of the endpoints of the parking zone
        let radiusVector = [(line.coor1.latitude - location.latitude) * mileConversion, (line.coor1.longitude - location.longitude) * mileConversion * cos(location.latitude/cosineConversion)]
        
        //uses dot product vector property to find the shortest distance between the user's location and parking zone
        let a = (Darwin.pow(lineVector[0], 2) + Darwin.pow(lineVector[1], 2))
        let b = (lineVector[0] * radiusVector[0] + lineVector[1] * radiusVector[1]) * 2
        let c = (Darwin.pow(radiusVector[0], 2) + Darwin.pow(radiusVector[1], 2)) - Darwin.pow(radius, 2)
        var discriminant = Darwin.pow(b, 2) - 4 * a * c
        
        //error with line formatting
        if(discriminant < 0)
        {
            return false
        }
        else
        {
            discriminant = sqrt(discriminant)
            let leftBound = (-b - discriminant)/(2*a)
            let rightBound = (-b + discriminant)/(2*a)
            
            //If location is contained within or touches the circular region
            if((leftBound >= 0 && leftBound <= 1) || (rightBound >= 0 && rightBound <= 1) || (leftBound <= 0 && rightBound >= 1))
            {
                return true
            }
            return false
        }
    }
}


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    //Storyboard references
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var radiusTextField: UITextField!
    
    //Location and Database references
    let locationManager = CLLocationManager()
    let ref = FIRDatabase.database().reference()
    
    //Local Variables
    var lineColor = UIColor.white.withAlphaComponent(0.5)
    var parkingLines: [MapLine] = []
    
    
    override func viewDidLoad()
    {
        //Updates Location Values
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        super.viewDidLoad()
        
        //Updates Map View
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self;
        
        //Adjust Button Size Font
        showButton.titleLabel?.adjustsFontSizeToFitWidth = true
        hideButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //Calls loadLines to retrieve lines from database
        loadLines()
    }
    
    /*
     Function that obtains location information
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error: " + error.localizedDescription)
    }
    
    /*
     Saves lines as a MapLine object
    */
    func loadLines()
    {
        ref.child("Zones").observe(.childAdded, with:
            { (snapshot) -> Void in
                let color = (snapshot.value as? NSDictionary)?["Color"] as? String ?? ""
                let coordinate1 = CLLocationCoordinate2D.init(latitude: CLLocationDegrees((snapshot.value as? NSDictionary)?["Coordinate1Latitude"] as? CGFloat ?? 0), longitude: CLLocationDegrees((snapshot.value as? NSDictionary)?["Coordinate1Longitude"] as? CGFloat ?? 0))
                let coordinate2 = CLLocationCoordinate2D.init(latitude: CLLocationDegrees((snapshot.value as? NSDictionary)?["Coordinate2Latitude"] as? CGFloat ?? 0), longitude: CLLocationDegrees((snapshot.value as? NSDictionary)?["Coordinate2Longitude"] as? CGFloat ?? 0))
                let detail = (snapshot.value as? NSDictionary)?["Detail"] as? String ?? ""
                let price = (snapshot.value as? NSDictionary)?["Price"] as? Double ?? 0
                let timing = (snapshot.value as? NSDictionary)?["Timings"] as? String ?? ""
                self.parkingLines.append(MapLine.init(color: color, coordinate1: coordinate1, coordinate2: coordinate2, details: detail, prices: price, timings: timing))
        })
    }
    
    /*
     Adds the lines as an overlay to mapview and draws it in the parking zone specified color
    */
    func drawLines()
    {
        for line in parkingLines
        {
            if(intersects(line: line))
            {
                lineColor = line.c
                self.mapView.add(line.l)
            }
        }
        self.mapView.reloadInputViews()
    }
    
    /*
     Hides lines from map display
    */
    func eraseLines()
    {
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    @IBAction func buttonPressed(button: UIButton)
    {
        switch((button.titleLabel?.text)!)
        {
        case("Show"):
            if(radiusTextField.text != "")
            {
                drawLines()
            }
        case("Hide"):
            eraseLines()
            radiusTextField.text = "0"
        default: break
        }
    }
    
    /*
     Renders parking zones (only accepts polylines as of now)
    */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        polyLineRenderer.strokeColor = lineColor;
        polyLineRenderer.lineWidth = 5;
        return polyLineRenderer;
    }
    
    /*
     Checks whether a given parking zone is within the circular region
    */
    func intersects(line: MapLine) -> Bool
    {
        return Intersect().check(location: CLLocationCoordinate2D.init(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), line: line, radius: Double(radiusTextField.text!)!)
    }
}



