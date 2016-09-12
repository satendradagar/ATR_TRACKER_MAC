//
//  AppDelegate.swift
//  Mac Configuration
//
//  Created by Satendra Singh on 31/08/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Cocoa
import SystemConfiguration

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet var mainTextView: NSTextView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
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
        CommonMacUtilies.getIPWithcompletionHandler { (ipAddress) in
         
            if nil != ipAddress{
            DataLogger.logMessage("IP Address", message:ipAddress)
            }

        }
        CPUUsageController.printNetwork();
        SystemEventLogger.getConsoleLogForAnHour();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

