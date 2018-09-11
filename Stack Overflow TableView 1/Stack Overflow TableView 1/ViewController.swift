//
//  ViewController.swift
//  Stack Overflow TableView 1
//
//  Created by Framework Access Point on 07/09/2018.
//  Copyright © 2018 Framework Central. All rights reserved.
//

import UIKit
import ALTableViewHelper

// Fake PlainPing class - calls back after 3 seconds with 2/3 of the callbacks being 'ok', and 1/3 in error
class PlainPing {
    static let error = NSError.init(domain:"user", code:123)
    static var cycle = 0
    class func ping(_ target:String, withTimeout:Double, completionBlock: @escaping (_ timeElapsed:Double?,_ error:Error? )->() ) {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {_ in
            cycle += 1
            if (cycle%3) == 0 {
                completionBlock( nil, error )
            } else {
                completionBlock( 3.0, nil ) }
            }
    }
}

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var serverStatusTable: UITableView!

    @objc let imageError = UIImage(named: "error")
    @objc let imageCheck = UIImage(named: "check")

    var pings = ["www.apple.com", "www.appleidontknowwhy.de", "www.apple.com", "www.apple.com"]
    
    var hosts = [String]() // hostnames which get pinged
    @objc var componentTextArray = [String]() // project names
    @objc var serverStatusMain = NSMutableArray() // not [String]() to allow changes to be observed

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // do not set dataSource, but instead:
        serverStatusTable.setHelperString(
            "section\n" +
            " body\n" +
            "  serverStatusCell * serverStatusMain\n" +
            "   $.viewWithTag:(8).text <~ @[1] == 'error' ? 'Error ' : 'Running '\n" +
            "   $.viewWithTag:(7).image <~ @[1] == 'error' ? imageError : imageCheck \n" +
            "   $.viewWithTag:(2).text <~ componentTextArray[@[0]]\n" +
            "", context:self)
        // @ is the value from the array (serverStatusMain), and $ is the serverStatusCell for @
        // The selector for UIView.viewWithTag() is 'viewWithTag:', which is why you see that in the helper string
        // Short arrays were added below as the values in serverStatusMain. In each short array:
        //   [0] is the index into hosts[] and componentTextArray[]
        //   [1] is the result of the ping, ie "check" or "error"
        //   so @[0] is the index and @[1] is the result of the ping
        
        serverStatusTable.delegate = self
        
        componentTextArray = ["Project 1", "Project 2", "Project 3", "Project 4"]
        hosts = pings
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidAppear(_ animated: Bool) {
        // initial ping host process when loading the view
        startHostRequest()
    }
    
    @IBAction func refreshBtnAction(_ sender: Any) {
        // manual ping host process when clicking the button "refresh"
        startHostRequest()
    }
    
    func startHostRequest () {
        // I thought you might need this here so that the 2nd and later ‘starts’ do the whole list
        pings = hosts
        
        // This will empty your UITableView
        serverStatusMain.removeAllObjects()
        
        print("refresh server status")
        pingNext()
    }
    
    func pingNext() {
        guard pings.count > 0 else {
            return
        }
        let ping = pings.removeFirst()
        PlainPing.ping(ping, withTimeout: 1.0, completionBlock:  { [weak self](timeElapsed:Double?, error:Error?) in
            if let me = self {
                if let latency = timeElapsed {
                    print("\(ping) latency (ms): \(latency)")
                    me.serverStatusMain.add([me.serverStatusMain.count, "check"])
                }
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    me.serverStatusMain.add([me.serverStatusMain.count, "error"])
                }
                me.pingNext()
            }
        })
    }
}

