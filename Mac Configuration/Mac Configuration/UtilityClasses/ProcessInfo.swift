//
//  ProcessInfo.swift
//  Mac Configuration
//
//  Created by Satendra Dagar on 04/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation
import Cocoa

class ProcessInfo {
    
    static func allRunningProcess() ->String{
        var appNames = ""
        
        let runningApps = NSWorkspace.sharedWorkspace().runningApplications
        
        for app:NSRunningApplication in runningApps {
            
        appNames += "\n\(app.localizedName!)"
            
        }
        return appNames;
    }
    
    static func allRunningProcessNames() ->NSArray{
        
        let appNames = NSMutableArray.init(capacity: 2)
        
        let runningApps = NSWorkspace.sharedWorkspace().runningApplications
        
        for app:NSRunningApplication in runningApps {
            if let nam = app.localizedName
            {
                appNames.addObject(nam)

            }
            
        }
        return appNames;
    }

}
