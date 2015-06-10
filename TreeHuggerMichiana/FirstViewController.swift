//
//  FirstViewController.swift
//  TreeHuggerMichiana
//
//  Created by Chris Johnson Bidler on 5/15/15.
//  Copyright (c) 2015 Chris Johnson Bidler. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController, MKMapViewDelegate, TreeModelDelegate, CLLocationManagerDelegate {
    
    let defaultZoomSpan : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.06125, longitudeDelta: 0.125)
    
    @IBOutlet var mapView : MKMapView?
    
    var locationManager : CLLocationManager?
    
    // This will obviously be pulled into a .plist entry when I have more than 'localhost' to work with
    var trees : TreeModel = TreeModel(restEndpoint: "http://localhost:8000/api/v1/tree/?limit=1000")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trees.delegate = self
        if(self.trees.trees.count == 0) {
            self.trees.fetchTrees()
        }
        if(CLLocationManager.locationServicesEnabled()) {
            self.locationManager = CLLocationManager()
            self.locationManager?.requestWhenInUseAuthorization()
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.locationManager?.delegate = self
            self.locationManager?.startUpdatingLocation()
        } else {
            println("Location Services not enabled")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.trees.didReceieveMemoryWarning()
    }
    
    // MKMapViewDelegate implementation
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if(annotation.isKindOfClass(MKUserLocation)) {
            return nil
        } else {
            if let treeView: MKPinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("treeView") as? MKPinAnnotationView
            {
                treeView.annotation = annotation
                return treeView
            } else {
                let treeView: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "treeView")
                treeView.pinColor = .Red
                treeView.animatesDrop = true
                treeView.canShowCallout = true
                return treeView
            }
        }
    }
    
    // TreeModelDelegate implementation
    func modelStateUpdated(modelState: [Tree]) {
        for tree in modelState {
            let treePoint: MKPointAnnotation = MKPointAnnotation()
            treePoint.coordinate = CLLocationCoordinate2D(latitude: tree.latitude!, longitude: tree.longitude!)
            treePoint.title = "It's A Tree!"
            treePoint.subtitle = "Condition: \(tree.condition!) Height: \(tree.height!), Diameter: \(tree.diameter!)"
            mapView?.addAnnotation(treePoint)
        }
        
    }
    
    func coordinateIsEqual(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> Bool {
        println("a: \(a.latitude) by \(a.longitude) \nb: \(b.latitude) by \(b.longitude)")
        return (a.longitude == b.longitude && a.latitude == b.latitude)
    }
    
    // CLLocationManagerDelegate implementation
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location: CLLocation = locations.last as? CLLocation {
            if(location.timestamp.timeIntervalSinceNow <= 1.0) {
                if(!(coordinateIsEqual(location.coordinate, b: self.mapView!.centerCoordinate))) {
                    self.mapView?.setRegion(MKCoordinateRegion(center: location.coordinate, span: self.defaultZoomSpan), animated: true)
                    println("Updated map center to lat: \(location.coordinate.latitude), long: \(location.coordinate.longitude)")
                }
            }
        } else {
            println("Got something that is not a CLLocation")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        println("True path taken")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("locationManager didFailWithError: \(error)")
    }
}

