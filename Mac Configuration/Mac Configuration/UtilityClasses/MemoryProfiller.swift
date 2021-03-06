//
//  MemoryProfiller.swift
//  Mac Configuration
//
//  Created by Satendra Singh on 01/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation
import Cocoa

struct MemoryProfiller {
    
     static var totalRam: Int64 {
        return Sysctl.memSize
    }

    static var totalRamDisplay: String {
        
        return NSByteCountFormatter.stringFromByteCount(totalRam, countStyle: .Binary)
    
    }

    static func memoryRepresentation( memorySize:Int64) -> String {
        
        return NSByteCountFormatter.stringFromByteCount(memorySize, countStyle: .Decimal)

    }
    static var usedRam:Int64{
        
        let vmstat = CommonMacUtilies.memoryStatus();

        let  freePages = Int64(vmstat.free_count + vmstat.inactive_count);

        let totalMemory = totalRam;
        let pageSize = vm_page_size
        let freeMemory = freePages * Int64(pageSize)
        let usedMemory = totalMemory - freeMemory
        return Int64(usedMemory)
    }
    
    static func getVolumeFreeSpace(volumePath:String) -> Dictionary<String,String> {

        var disk = Dictionary<String,String>()

        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(volumePath)
            let freeSize = Int64(fileAttributes[NSFileSystemFreeSize] as! CGFloat)
            let totalSize = Int64(fileAttributes[NSFileSystemSize] as! CGFloat)
            disk["MountName"] = volumePath
            disk["Total"] = totalSize.description
            disk["Free"] = freeSize.description
            return disk

//            return "\(memoryRepresentation(freeSize)) free of \(memoryRepresentation(totalSize)) :[\(volumePath)]"
            
        } catch { }
        return disk
    }

//    static func getMountedVolumesFreeSpace() -> String {
//        do {
//            if let fileURLS:[NSURL] = try NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys(nil, options:.SkipHiddenVolumes)
//            {
//                var finalUsageStr = "";
//                for url in fileURLS {
//                    finalUsageStr += "\n";
//                    finalUsageStr += MemoryProfiller.getVolumeFreeSpace(url.path!)
//                }
//                return finalUsageStr;
//            }
//            
//        } catch { }
//        
//        
//        return "Not found"
//    }

    
    static func getMountedVolumes() -> NSArray {
        let volumes = NSMutableArray.init(capacity: 1)

        do {
            if let fileURLS:[NSURL] = try NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys(nil, options:.SkipHiddenVolumes)
            {
//                var finalUsageStr = "";
                for url in fileURLS {
//                    finalUsageStr += "\n";
//                    finalUsageStr += MemoryProfiller.getVolumeFreeSpace(url.path!)
                    volumes.addObject(MemoryProfiller.getVolumeFreeSpace(url.path!))
                }
                return volumes;
            }
            
        } catch { }
        
        
        return volumes
    }
  

}
