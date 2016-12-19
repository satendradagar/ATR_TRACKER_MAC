//
//  main.swift
//  MacConfig
//
//  Created by Satendra Singh on 19/12/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation

//print("Hello, World!")


func applicationDidFinishLaunching() {
    // Insert code here to initialize your application
    //        CPUUsageController.samplePrint();
    //        return;
    DataLogger.logMessage("OS Name", message: SystemInformationController.osName()!)
    DataLogger.logMessage("OS Version", message: SystemInformationController.osVersion()!)
    DataLogger.logMessage("Machine Name", message: SystemInformationController.machineName()!)
    DataLogger.logMessage("User Domain", message: SystemInformationController.domainName()!)
    DataLogger.logMessage("User Name", message: SystemInformationController.loggedInUser()!)
    DataLogger.logMessage("Computer Model", message: SystemInformationController.computerModel()!)
    DataLogger.logMessage("Motherboard name", message: SystemInformationController.motherBoardType()!)
    DataLogger.logMessage("Processor", message: SystemInformationController.processorType()!)
    DataLogger.logMessage("Last Boot Time", message: (SystemInformationController.uptime()?.descriptionWithLocale(NSLocale.currentLocale()))!)
    
    DataLogger.logMessage("Ram", message:MemoryProfiller.totalRamDisplay)
    DataLogger.logMessage("UsedRam", message:MemoryProfiller.memoryRepresentation(MemoryProfiller.usedRam))
    
    DataLogger.logMessage("Video Card", message:DispayCard.videoCardDetails)
    DataLogger.logMessage("Audio Card", message:DispayCard.audioCardDetails)
    DataLogger.logMessage("Hard Disk", message:MemoryProfiller.getMountedVolumesFreeSpace())
    // Setup SMC
    do {
        try SMCKit.open()
    } catch {
        print(error);
        exit(EX_UNAVAILABLE)
    }
    
    DataLogger.logMessage("CPU Load", message:CPUInfo.cpuLoadPercentString())
    DataLogger.logMessage("Temperatures", message:CPUInfo.printTemperatureInformation())
    DataLogger.logMessage("Fan", message:CPUInfo.printFanInformation())
    SMCKit.close();
    
    DataLogger.logMessage("All Running Processes", message:ProcessInfo.allRunningProcess())
    
    //        let smcFanCount          = try! SMCKit.fanCount()
    //        let smcRPM               = try! SMCKit.fanCurrentSpeed(0)
    //
    //        print("\(smcFanCount)");
    //        print("\(smcRPM)");
    //        CPUInfo.printFanInformation();
    //        CPUInfo.printTemperatureInformation();
    //        CPUInfo.cpuLoadDetails()
    
    //        CommonMacUtilies.getCpuDetails();
    dispatch_async(dispatch_get_main_queue()) {
        
        let logs = SystemEventLogger.getConsoleLogForAnHour();
        var allMeesages = String();
        
        if (logs != nil) {
            
            for msg in logs! {
                allMeesages += "\n"
                allMeesages += msg
            }
            
        }
        DataLogger.logMessage("Last Hour events:", message:allMeesages)
        
        
    };
    CommonMacUtilies.getIPWithcompletionHandler { (ipAddress) in
        
        if nil != ipAddress{
            DataLogger.logMessage("IP Address", message:ipAddress)
        }
        let dict = DataLogger.logDictionary()
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
        
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        //            let task = Process()
        //            task.launchPath = cmd
        //            task.arguments = args
        
        //            let outpipe = NSPipe()
        //            task.standardOutput = outpipe
        //
        print(jsonString)
        exit(0)
    }
    //        CPUUsageController.printNetwork();
}

applicationDidFinishLaunching()

NSRunLoop.currentRunLoop().run();  // Swift < 3.0
