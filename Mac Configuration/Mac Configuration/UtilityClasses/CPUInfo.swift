//
//  CPUInfo.swift
//  Mac Configuration
//
//  Created by Satendra Dagar on 03/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation

let MaximumNetworkThroughput = Network.Throughput(input: 1_258_291 /* Download: 1,2 MB/s */, output: 133_120 /* Upload: 120 Kb/s */)

let cpu = CPU()

/// The latest cpu load
var cpuLoad: [Double]?

/// The network stats
let network = Network(maximumThroughput: MaximumNetworkThroughput)

/// The latest network load
var networkLoad = Network.Load(input: 0, output: 0)

var timer:Timer?

class CPUInfo {
   
    static func fanDetails() -> NSArray{
        //    print("-- Fan --")
//        var fanDescription = "\n";
        let fanObjects = NSMutableArray.init(capacity: 1)
        
        let allFans: [Fan]
        do {
            allFans = try SMCKit.allFans()
        } catch {
            print(error)
            return fanObjects
        }
        
        if allFans.count == 0 {
//            fanDescription += "\nNo fans found";
            fanObjects.addObject("No fans found")
            //        print("No fans found")
        }
        
        for fan in allFans {
            //        print("[id \(fan.id)] Fan Name:\(fan.name)")
            //        print("\tMin:      \(fan.minSpeed) RPM")
            //        print("\tMax:      \(fan.maxSpeed) RPM")
            var fanInfo = ""
            
            fanInfo += "[id \(fan.id)] Fan Name:\(fan.name)";
            fanInfo += "\tMin:      \(fan.minSpeed) RPM";
            fanInfo += "\tMax:      \(fan.maxSpeed) RPM";
            
            
            guard let currentSpeed = try? SMCKit.fanCurrentSpeed(fan.id) else {
                print("\n\tCurrent:  NA")
                fanInfo += "\tCurrent:  NA";
                fanObjects.addObject(fanInfo)

                return fanObjects
            }
            fanInfo += "\tCurrent:  \(currentSpeed) RPM";
            fanObjects.addObject(fanInfo)
            //        print("\tCurrent:  \(currentSpeed) RPM")
        }
        return fanObjects;
    }

static func printFanInformation() -> String{
//    print("-- Fan --")
    var fanDescription = "\n";
    
    let allFans: [Fan]
    do {
        allFans = try SMCKit.allFans()
    } catch {
        print(error)
        return fanDescription
    }
    
    if allFans.count == 0 {
        fanDescription += "\nNo fans found";
//        print("No fans found")
    }
    
    for fan in allFans {
//        print("[id \(fan.id)] Fan Name:\(fan.name)")
//        print("\tMin:      \(fan.minSpeed) RPM")
//        print("\tMax:      \(fan.maxSpeed) RPM")

        fanDescription += "\n[id \(fan.id)] Fan Name:\(fan.name)";
        fanDescription += "\n\tMin:      \(fan.minSpeed) RPM";
        fanDescription += "\n\tMax:      \(fan.maxSpeed) RPM";

        
        guard let currentSpeed = try? SMCKit.fanCurrentSpeed(fan.id) else {
            print("\n\tCurrent:  NA")
            fanDescription += "\n\tCurrent:  NA";

            return fanDescription
        }
        fanDescription += "\n\tCurrent:  \(currentSpeed) RPM";
//        print("\tCurrent:  \(currentSpeed) RPM")
    }
    return fanDescription;
}
    
    
    static func temperatureSensors(known: Bool = true) -> NSArray{
        //        print("-- Temperature --")
//        var temperatureStr = ""
        let sensorObjs = NSMutableArray.init(capacity: 1)
        
        let sensors: [TemperatureSensor]
        do {
            if known {
                sensors = try SMCKit.allKnownTemperatureSensors().sort
                    { $0.name < $1.name }
            } else {
                sensors = try SMCKit.allUnknownTemperatureSensors()
            }
            
        } catch {
            print(error)
            return sensorObjs
        }
        
        
        let sensorWithLongestName = sensors.maxElement { $0.name.characters.count <
            $1.name.characters.count }
        
        guard let longestSensorNameCount = sensorWithLongestName?.name.characters.count else {
            print("No temperature sensors found")
//            temperatureStr += "\nNo temperature sensors found";
            sensorObjs.addObject("No temperature sensors found")
            return sensorObjs
        }
        
        
        for sensor in sensors {
            var sensorDetails = ""
            
            let padding = String(count: longestSensorNameCount -
                sensor.name.characters.count,
                                 repeatedValue: Character(" "))
            
            //            print("\(sensor.name + padding)   \(sensor.code.toString())  ", terminator: "")
            sensorDetails += "\(sensor.name + padding)   \(sensor.code.toString())  ";
            
            guard let temperature = try? SMCKit.temperature(sensor.code) else {
                //                print("NA")
                sensorDetails += "NA"
                sensorObjs.addObject("NA")
                return sensorObjs
            }
            
            sensorDetails += "\(temperature)°C ";
            //            print("\(temperature)°C ")
            sensorObjs.addObject(sensorDetails)
        }
        return sensorObjs;
    }

   static func printTemperatureInformation(known: Bool = true) -> String{
//        print("-- Temperature --")
    var temperatureStr = ""
    
        let sensors: [TemperatureSensor]
        do {
            if known {
                sensors = try SMCKit.allKnownTemperatureSensors().sort
                    { $0.name < $1.name }
            } else {
                sensors = try SMCKit.allUnknownTemperatureSensors()
            }
            
        } catch {
            print(error)
            return ""
        }
        
        
        let sensorWithLongestName = sensors.maxElement { $0.name.characters.count <
            $1.name.characters.count }
        
        guard let longestSensorNameCount = sensorWithLongestName?.name.characters.count else {
            print("No temperature sensors found")
            temperatureStr += "\nNo temperature sensors found";
            return ""
        }
        
        
        for sensor in sensors {
            let padding = String(count: longestSensorNameCount -
                sensor.name.characters.count,
                                 repeatedValue: Character(" "))
            
//            print("\(sensor.name + padding)   \(sensor.code.toString())  ", terminator: "")
            temperatureStr += "\n\(sensor.name + padding)   \(sensor.code.toString())  ";

            
            guard let temperature = try? SMCKit.temperature(sensor.code) else {
//                print("NA")
                temperatureStr += "\nNA"
                return ""
            }
            
            temperatureStr += "\(temperature)°C ";
//            print("\(temperature)°C ")
        }
    return temperatureStr;
    }
    
    static func cpuLoadPercentString() -> String {
        
        return "\(cpu.cpuLoadPercent())%"
    }
    
    static func cpuLoadDetails() -> String {
//        /// The cpu stats
//        let cpu = CPU()
//        
//        /// The latest cpu load
//        var cpuLoad: [Double]
//        
//        /// The network stats
//        let network = Network(maximumThroughput: MaximumNetworkThroughput)
//        
//        /// The latest network load
//        var networkLoad = Network.Load(input: 0, output: 0)
//
        cpuLoad = cpu.load()
        networkLoad = network.load()

//        /// Get the current load values and update the statusView
//        cpuLoad = cpu.load()
//        networkLoad = network.load()
//        print(cpuLoad)
//        print(networkLoad)
        timer = Timer.repeatEvery(2) {  inTimer in
            
            printLoad(cpu, network: network)
        }

        return "";
    }
    
    static func printLoad(cpu:CPU,network:Network){
        /// Get the current load values and update the statusView
        let cpuLoad = cpu.load()
        let networkLoad = network.load()
        print(cpuLoad)
        print(networkLoad)

    }
}
