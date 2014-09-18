//
//  ViewController.swift
//  AutoLayoutDemo
//
//  Created by 斉藤 祐輔 on 2014/09/18.
//  Copyright (c) 2014年 JIBUNSTYLE Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var _webView: UIWebView!
    
    let startUrl = "http://www.jibunstyle.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let req = NSURLRequest(URL: NSURL(string: startUrl))
        _webView.loadRequest(req)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

