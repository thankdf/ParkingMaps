//
//  ViewController.swift
//  MapTest
//
//  Created by yoho chen on 10/19/16.
//  Copyright © 2016 Yoho. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

private extension MKPolyline {
    convenience init(coordinates coords: Array<CLLocationCoordinate2D>) {
        let unsafeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: coords.count)
        unsafeCoordinates.initialize(from: coords)
        self.init(coordinates: unsafeCoordinates, count: coords.count)
        unsafeCoordinates.deallocate(capacity: coords.count)
    }
}

struct CONSTANT
{
    static let whiteColor = UIColor.white.withAlphaComponent(0.5)
    static let purpleColor = UIColor.purple.withAlphaComponent(0.5)
    static let orangeColor = UIColor.orange.withAlphaComponent(0.5)
    static let greenColor = UIColor.green.withAlphaComponent(0.5)
    static let blueColor = UIColor.blue.withAlphaComponent(0.5)
    static let brownColor = UIColor.brown.withAlphaComponent(0.5)
    static let magentaColor = UIColor.magenta.withAlphaComponent(0.5)
}

struct variables
{
    static var lineColor = CONSTANT.whiteColor
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        super.viewDidLoad()
        self.mapView.delegate = self;
        drawAnnotations()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func drawAnnotations()
    {
        let bluePoints: [[CLLocationCoordinate2D]] = [[CLLocationCoordinate2DMake(37.337509, -121.882320), CLLocationCoordinate2DMake(37.337542, -121.882231)]]
        let greenPoints: [[CLLocationCoordinate2D]] = [[CLLocationCoordinate2DMake(37.337500, -121.882310), CLLocationCoordinate2DMake(37.337490, -121.88320)]]
        variables.lineColor = CONSTANT.blueColor
        for point in bluePoints
        {
            let polyLine = MKPolyline.init(coordinates: point)
            mapView.add(polyLine)
        }
        variables.lineColor = CONSTANT.greenColor
        for point in greenPoints
        {
            let polyLine = MKPolyline.init(coordinates: point)
            mapView.add(polyLine)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        polyLineRenderer.strokeColor = variables.lineColor;
        polyLineRenderer.lineWidth = 5;
        return polyLineRenderer;
    }
}



