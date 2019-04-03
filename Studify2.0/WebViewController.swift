//
//  WebViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 4/3/19.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import Foundation
import WebKit

class WebViewController : UIViewController, WKUIDelegate {
    
    var reason = ""
    
    @IBOutlet weak var webViewContainerView: UIView!
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reason == "" {
            print("Error? Reason empty when opening WebViewController")
        }
        else if reason == "reportBug" {
            self.navigationItem.title = "Bug Report"
            let myURL = URL(string:"https://docs.google.com/forms/d/e/1FAIpQLSegOeSlfnaC4U8W4JjPLtKaGYXNU1o4ZLQKTI1cjwBBtOLLnQ/viewform")
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }
        else if reason == "provideFeedback" {
            self.navigationItem.title = "Provide Feedback"
            let myURL = URL(string:"https://docs.google.com/forms/d/e/1FAIpQLSfeaTAeHCgZCLdPvJE6xuiF0jqkLrdmqydKyLRaw8s1--JrpA/viewform")
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }
        
    }
    
}


