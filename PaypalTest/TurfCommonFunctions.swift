//
//  TurfCommonFunctions.swift
//  PaypalTest
//
//  Created by Sandip Ghosh on 17/02/17.
//  Copyright © 2017 Sandip Ghosh. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class CommonFunctions: NSObject {
    
    func alert_for(title: String!, message: String!) {
        
        let alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButton(withTitle: "OK")
        alertView.show()
    }
    
    func bottom_border(view: UIView!, table_view: UITableView!, cell: UITableViewCell) {
        
        let border_width = view.frame.size.width
        let view1 = UIView(frame: CGRect(x: 0, y: table_view.rowHeight - 1, width: border_width, height:0.3))
        view1.backgroundColor = UIColor(red: 203.0/255.0, green: 203.0/255.0, blue: 208.0/255.0, alpha: 1.0)
        cell.addSubview(view1)
    }
    
}

public class CheckNetwork {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {_ in 
            //SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability as! SCNetworkReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
}
