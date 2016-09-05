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
        let total:Int64 = Int64(vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count);
//            let  wired:double = vmstat.wire_count / total;
//            let  active :double= vmstat.active_count / total;
//            let  inactive:double = vmstat.inactive_count / total;
        var  freePages = Int64(vmstat.free_count);

        let totalMemory = totalRam;
//        let pageSize = vm_page_size
//        let freePages = CommonMacUtilies.freeMemory()
        freePages = (freePages * totalMemory)/total
//        let totalFreeSize = Int64(freePages) * Int64(pageSize)
        
        let usedMemory = totalMemory - freePages
        return Int64(usedMemory)
//        //HOST_VM_INFO_COUNT
//        let count:mach_msg_type_number_t ;
//        let vmstat:vm_statistics_data_t ;
//        if(KERN_SUCCESS != host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count))
        // An error occurred
    }
    
    static func getVolumeFreeSpace(volumePath:String) -> String {
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(volumePath)
             let freeSize = Int64(fileAttributes[NSFileSystemFreeSize] as! CGFloat)
             let totalSize = Int64(fileAttributes[NSFileSystemSize] as! CGFloat)
            
            return "\(memoryRepresentation(freeSize)) free of \(memoryRepresentation(totalSize)) :[\(volumePath)]"
            
        } catch { }
        return "Not found"
    }

    static func getMountedVolumesFreeSpace() -> String {
        do {
            if let fileURLS:[NSURL] = try NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys(nil, options:.SkipHiddenVolumes)
            {
                var finalUsageStr = "";
                for url in fileURLS {
                    finalUsageStr += "\n";
                    finalUsageStr += MemoryProfiller.getVolumeFreeSpace(url.path!)
                }
                return finalUsageStr;
            }
            
        } catch { }
        return "Not found"
    }

    

}
