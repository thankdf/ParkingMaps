//
//  MapLine.swift
//  MapTest
//
//  Created by Kevin Dang on 12/3/16.
//  Copyright © 2016 Yoho. All rights reserved.
//

import UIKit
import MapKit

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
    static let White = UIColor.white.withAlphaComponent(0.5)
    static let Purple = UIColor.purple.withAlphaComponent(0.5)
    static let Orange = UIColor.orange.withAlphaComponent(0.5)
    static let Green = UIColor.green.withAlphaComponent(0.5)
    static let Blue = UIColor.blue.withAlphaComponent(0.5)
    static let Brown = UIColor.brown.withAlphaComponent(0.5)
    static let Magenta = UIColor.magenta.withAlphaComponent(0.5)
}

class MapLine: NSObject
{
    var c: UIColor = UIColor.white.withAlphaComponent(0.5)
    var l: MKPolyline
    var coor1: CLLocationCoordinate2D
    var coor2: CLLocationCoordinate2D
    var d: String
    var p: Double
    var t: String
    
    init(color: String, coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D, details: String, prices: Double, timings: String)
    {
        switch(color)
        {
        case("White"): c = CONSTANT.White
        case("Purple"): c = CONSTANT.Purple
        case("Orange"): c = CONSTANT.Orange
        case("Green"): c = CONSTANT.Green
        case("Blue"): c = CONSTANT.Blue
        case("Brown"): c = CONSTANT.Brown
        case("Magenta"): c = CONSTANT.Magenta
        default: break
        }
        l = MKPolyline.init(coordinates: [coordinate1, coordinate2])
        coor1 = coordinate1
        coor2 = coordinate2
        d = details
        p = prices
        t = timings
    }
    
    
    
}
