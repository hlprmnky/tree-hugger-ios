//
//  Model.swift
//  TreeHuggerMichiana
//
//  Created by Chris Johnson Bidler on 5/16/15.
//  Copyright (c) 2015 Helper Monkey Software LLC. All rights reserved.
//

import Foundation

struct Tree {
  var latitude, longitude : Double?
  var id : Int
  var condition, diameter, height: String?
  var images : [AnyObject]?
}

protocol TreeModelDelegate {
  func modelStateUpdated(modelState: [Tree])
  
}

struct TreeModel {
  let endpoint: String
  var delegate:TreeModelDelegate? = nil
  lazy var trees: [Tree] = []
  
  init(restEndpoint endpoint: String) {
    self.endpoint = endpoint  
  }
  
  mutating func didReceieveMemoryWarning() {
    self.trees.removeAll(keepCapacity: false)
  }
  
  mutating func fetchTrees() {
    let urlRequest : NSURLRequest = NSURLRequest(URL: NSURL(string: self.endpoint)!)
    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue(), completionHandler:{
      (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
      if let anError = error
      {
        println("Got an error: \(anError)")
      }
      else
      {
        var jsonError: NSError?
        let post = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as! NSDictionary
        if let aJSONError = jsonError
        {
          // got an error while parsing the data, need to handle it
          println("error parsing result from \(self.endpoint): \(aJSONError)")
        }
        else
        {
          if let objects : NSArray = post["objects"] as? NSArray
          {
            for object in objects {
              if let jsonTree : NSDictionary = object as? NSDictionary
              {
                let tree: Tree = Tree(latitude: jsonTree["latitude"] as? Double,
                                      longitude: jsonTree["longitude"] as? Double,
                                             id: jsonTree["id"] as! Int,
                                      condition: jsonTree["condition"] as? String,
                                       diameter: jsonTree["diameter"] as? String,
                                         height: jsonTree["height"] as? String,
                                         images: jsonTree["images"] as? [AnyObject])
                if(self.trees.filter({tree.id == $0.id}).isEmpty)
                {
//                  println("Adding tree \(tree.id) at lat \(tree.latitude), long \(tree.longitude)")
                  self.trees.append(tree)
                } else {
                  println("Not adding tree, we already have a tree for ID \(tree.id)")
                }
              }
              else
              {
                println("Object \(object.description) is not an NSDictionary, can't make a Tree() from it")
              }
            }
          }
          self.delegate!.modelStateUpdated(self.trees)
        }
      }
    })
  }
}

