//
//  Strew.swift
//  strew-sample
//
//  Created by atsushi.kambayashi on 2015/06/26.
//  Copyright (c) 2015年 ichiban-yari. All rights reserved.
//

import Foundation
import UIKit

protocol StrewDelegate {
  func strewOpen() -> Void
  func strewReceive(data: String) -> Void
  func strewError() -> Void
  func strewClose() -> Void
}

class Strew : NSObject, UIWebViewDelegate {
  static let baseUrl = "http://localhost:8080/"
  static let jsScheme = "appenginechannel"
  
  enum Method : String {
    case Open = "open"
    case Receive = "receive"
    case Error = "error"
    case Close = "close"
  }
  
  struct Parameters {
    let token: String
    let channel: String
  }
  
  class func createInstance(params:Parameters, delegate: StrewDelegate) -> Strew {
    let view = UIWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var result = Strew(params: params, view: view, delegate: delegate)
    view.delegate = result
    view.loadRequest(makeRequest(params))
    
    return result
  }
  
  class func makeRequest(params:Parameters) -> NSURLRequest {
    let url = NSURL(string: "\(baseUrl)/channel/ios/start/\(params.token)/\(params.channel)")
    var req = NSURLRequest(URL: url!)
    return req
  }
  
  init(params: Parameters, view: UIWebView, delegate: StrewDelegate) {
    self.params = params
    self.view = view
    self.delegate = delegate
  }
  
  var delegate: StrewDelegate
  var params:Parameters
  var view:UIWebView
  
  func urlComponetsToDictionary(url: String) -> Dictionary<String, String> {
    var dict:Dictionary<String, String> = Dictionary<String, String>()
    if let urlComponents = NSURLComponents(string: url) {
      for (var i=0; i < urlComponents.queryItems?.count; i++) {
        let item = urlComponents.queryItems?[i] as! NSURLQueryItem
        dict[item.name] = item.value
      }
    }
    
    return dict

  }
  
  // UIWebViewDelegate
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    let scheme = request.URL?.scheme
    if scheme == Strew.jsScheme {
      if let parent = view.superview {
        println("removed from superview")
        view.removeFromSuperview()
      }
      if let data = view.stringByEvaluatingJavaScriptFromString("Strew.fetch();")?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        if let commandData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as?  Dictionary<String, AnyObject> {
          if let commands = commandData["commands"] as? Array<Dictionary<String, AnyObject>> {
            let params = self.params
            for item in commands {
              dispatch_async(
                dispatch_get_main_queue(),
                { [unowned self] () in
                  if let method = item["command"] as? String {
                    switch method {
                    case Method.Open.rawValue:
                      self.delegate.strewOpen()
                    case Method.Receive.rawValue:
                      if let data = item["data"] as? String {
                        self.delegate.strewReceive(data)
                      }
                      else {
                        self.delegate.strewReceive("")
                      }
                    case Method.Error.rawValue:
                      self.delegate.strewError()
                    case Method.Close.rawValue:
                      self.delegate.strewClose()
                    default:
                      println("strew: Unknown method. method:\(method)")
                    }
                  }
                }
                )
            }
            //println(commands)
          }
        }
        else {
          println("Received appenginechannel but unknown data")
        }
      }
      
      return false
    }
    
    return true
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    println("Start Loading \(webView.request?.URL?.absoluteString)")
    println("")
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    println("Finish Loading \(webView.request?.URL?.absoluteString)")
    println("")
  }
}
