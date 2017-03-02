//
//  ViewController.swift
//  EarthQuake
//
//  Created by vm mac on 17/12/2016.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
        var TableData:Array< String > = Array < String >()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell");
            loadUrl(link: "http://www.seismi.org/api/eqs/", callback:(processJson as? ViewController.MyClosure)!); // call http GET with url as param
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            return "Magniture - Region - Datetime"; // make a section header
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return TableData.count;
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = TableData[indexPath.row];
            return cell;
        }
        // debug code
        func tableView(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath) {
            print("clicked \(TableData[indexPath.row])") // debugging
        }
    
    public typealias MyClosure = (_ data: NSData) -> Void; // define closure type
        /*
         -re-usable module, async get, single thread
         -input url
         -input process data module as closure
         -escape if fail/error
         -else call callback processJson with data as param type NSdata
         */
    func loadUrl(link:String, callback: @escaping MyClosure ){
    
            let url:URL = URL(string: link)!
            let session = URLSession.shared;
            let request = NSMutableURLRequest(url: url);
            request.httpMethod = "GET";
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData;
            let task = session.dataTask(with: request as URLRequest, completionHandler: {
                (data, response, error) in
                
                guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                    // if anything wrong, dont go further
                    let logString = "error \(error)";
                    print(logString);
                    return;
                }
                if (callback != nil) { // as closure with void, assume cond is true
                    callback(data! as NSData)
                }
            })
            task.resume();
            
        }
        
        /*
         -custom format model specific for json obj structure
         -input: json obj
         -call table reload data as result.
         */
        func processJson(data: NSData) -> Void{
            var myar: Array< String > = Array < String >();
            let json: Any?
            do {
                json  = try JSONSerialization.jsonObject(with: data as Data, options: [])
            }
            catch { return }
            
            if let dataList = json as? NSDictionary{ //1- is it a json obj?
                if let ar1 = dataList["earthquakes"] as? NSArray {          //2- earthquake array?
                    for i in 0 ..< ar1.count {                              //3- loop thru array
                        if let data_obj = ar1[i] as? NSDictionary{          // get an json obj
                            let region = data_obj["region"] as? String;  // get the region string
                            let magnitude = data_obj["magnitude"] as? String;  // and magniture string
                            let atTime = data_obj["timedate"] as? String;
                            myar.append(magnitude! + " - " + region! + " - " + atTime!) // add to custom array for sorting
                            
                        }
                    } //3- array loop
                } //2-
                TableData = myar.sorted(by: >); // big number goes first
            } //1-
            DispatchQueue.main.async(execute: {self.tableRefresh()}) // reload data
        } //pJson
        
        func tableRefresh() {
            self.tableView.reloadData()
        }
        
} //Vcontroller
