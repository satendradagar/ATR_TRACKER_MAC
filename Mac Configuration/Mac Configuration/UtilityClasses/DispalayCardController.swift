//
//  DispalayCardController.swift
//  Mac Configuration
//
//  Created by Satendra Singh on 01/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation
import Cocoa

struct DispayCard {
    
    static var videoCardDetails: NSArray {
        
        return CommonMacUtilies.videoCardInfo()
        
    }

    static var audioCardDetails: NSArray {
        
        return CommonMacUtilies.getAudioDevices()
        
    }

}
