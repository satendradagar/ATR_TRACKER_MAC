//
//  SystemInformationController.swift
//  Mac Configuration
//
//  Created by Satendra Singh on 31/08/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation
import Cocoa
import SystemConfiguration
/*
 deviceObject.hostName = [[NSHost currentHost] localizedName];
 NSString * operatingSystemVersionString = [[NSProcessInfo processInfo] operatingSystemVersionString];
 size_t len = 0;
 NSString *modelName = nil;
 sysctlbyname("hw.model", NULL, &len, NULL, 0);
 if (len) {
 char *model = malloc(len*sizeof(char));
 sysctlbyname("hw.model", model, &len, NULL, 0);
 printf("%s\n", model);
 modelName = [NSString stringWithFormat:@"%s",model];
 free(model);
 }

 */

class SystemInformationController {
    
   static func osName() -> String? {
        
        let osDict: NSDictionary = NSDictionary.init(contentsOfFile: "/System/Library/CoreServices/SystemVersion.plist")!;
//    print(osDict)
    return osDict["ProductName"] as! String?;
    }
    
    static func osVersion() -> String? {
        
        let osDict: NSDictionary = NSDictionary.init(contentsOfFile: "/System/Library/CoreServices/SystemVersion.plist")!;
        return osDict["ProductVersion"] as! String?;
    }

    static func machineName() -> String? {

        return Sysctl.hostName.stringByReplacingOccurrencesOfString(".local", withString: "")
    }

   static func domainName() -> String? {
    
      return NSHost.currentHost().name
    
    }
    
   static func loggedInUser() -> String? {
    
        return "\(NSFullUserName())(\(NSUserName()))"
//        return NSHost.currentHost().localizedName
    }

    static func computerModel() -> String? {
        
        return Sysctl.model
    }

    static func motherBoardType() -> String? {
        
        return "\(Sysctl.machine)(\(Sysctl.model))"

    }
    
    static func processorType() -> String? {
        
        return Sysctl.cpuName
    }
    
    
    /// How long has the system been up?
     static func uptime() -> NSDate? {
        var currentTime = time_t()
        var bootTime    = timeval()
        var mib         = [CTL_KERN, KERN_BOOTTIME]
        
        // NOTE: Use strideof(), NOT sizeof() to account for data structure
        // alignment (padding)
        // http://stackoverflow.com/a/27640066
        // https://devforums.apple.com/message/1086617#1086617
        var size = strideof(timeval)
        
        let result = sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)
        
        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = "
                    + "\(result)")
            #endif
            
            return nil
        }
        
        
        // Since we don't need anything more than second level accuracy, we use
        // time() rather than say gettimeofday(), or something else. uptime
        // command does the same
        time(&currentTime)
        let tvSec: Int = bootTime.tv_sec;
        let timeInt: NSTimeInterval = (Double(tvSec)  + Double(bootTime.tv_usec) / 1000000)
                
        return NSDate.init(timeIntervalSince1970: timeInt)
    }
    
}