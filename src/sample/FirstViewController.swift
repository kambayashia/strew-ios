//
//  ViewController.swift
//  strew
//
//  Created by atsushi.kambayashi on 2015/06/27.
//  Copyright (c) 2015年 ichiban-yari. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, StrewDelegate {
  var strew: Strew?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    strew = Strew.createInstance(
      Strew.Parameters(
        token: "f910da0db7bad1a1edbf850c9c98782d5349821a4a8df2f955bd922ecb9cbc74",
        channel: "koko"
      ),
      delegate: self
    )
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    view.addSubview(strew!.view)
  }
  
  // StrewDelegate
  func strewOpen() {
    println("Channel open")
  }
  
  func strewReceive(data: String) {
    println("Receive message. msg:\(data)")
  }
  
  func strewError() {
    println("Channel error")
  }
  func strewClose() {
    println("Channel close")
  }
}

