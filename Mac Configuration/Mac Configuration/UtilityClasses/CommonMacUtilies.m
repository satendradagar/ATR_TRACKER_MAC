//
//  CommonMacUtilies.m
//  Mac Configuration
//
//  Created by Satendra Singh on 01/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

#import "CommonMacUtilies.h"
#import <CoreAudio/CoreAudio.h>
#import <asl.h>

struct cpusample {
    uint64_t totalSystemTime;
    uint64_t totalUserTime;
    uint64_t totalIdleTime;
    
};

void sample(struct cpusample *sample)
{
    processor_cpu_load_info_t cpuLoad;
    mach_msg_type_number_t processorMsgCount;
    natural_t processorCount;
    
    uint64_t totalSystemTime = 0, totalUserTime = 0, totalIdleTime = 0;
    
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount, (processor_info_array_t *)&cpuLoad, &processorMsgCount);
    
    for (natural_t i = 0; i < processorCount; i++) {
        
        // Calc load types and totals, with guards against 32-bit overflow
        // (values are natural_t)
        uint64_t system = 0, user = 0, idle = 0;
        
        system = cpuLoad[i].cpu_ticks[CPU_STATE_SYSTEM];
        user = cpuLoad[i].cpu_ticks[CPU_STATE_USER] + cpuLoad[i].cpu_ticks[CPU_STATE_NICE];
        idle = cpuLoad[i].cpu_ticks[CPU_STATE_IDLE];
        printf("----%llu--%llu----%llu----",system,user,idle);
        totalSystemTime += system;
        totalUserTime += user;
        totalIdleTime += idle;
    }
    sample->totalSystemTime = totalSystemTime;
    sample->totalUserTime = totalUserTime;
    sample->totalIdleTime = totalIdleTime;
}


@implementation CommonMacUtilies


+(vm_statistics_data_t)memoryStatus{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if(KERN_SUCCESS != host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count)){
        NSLog(@"kernel code failed");
    }
        return vmstat;
}

+(NSString *)videoCardInfo{
    
    NSString *s = @"";
        // Check the PCI devices for video cards.
    CFMutableDictionaryRef match_dictionary = IOServiceMatching("IOPCIDevice");
    
        // Create a iterator to go through the found devices.
    io_iterator_t entry_iterator;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault,
                                     match_dictionary,
                                     &entry_iterator) == kIOReturnSuccess)
        {
            // Actually iterate through the found devices.
        io_registry_entry_t serviceObject;
        while ((serviceObject = IOIteratorNext(entry_iterator))) {
                // Put this services object into a dictionary object.
            CFMutableDictionaryRef serviceDictionary;
            if (IORegistryEntryCreateCFProperties(serviceObject,
                                                  &serviceDictionary,
                                                  kCFAllocatorDefault,
                                                  kNilOptions) != kIOReturnSuccess)
                {
                    // Failed to create a service dictionary, release and go on.
                IOObjectRelease(serviceObject);
                continue;
                }
            
                // If this is a GPU listing, it will have a "model" key
                // that points to a CFDataRef.
            const void *model = CFDictionaryGetValue(serviceDictionary, @"model");
            if (model != nil) {
                if (CFGetTypeID(model) == CFDataGetTypeID()) {
                        // Create a string from the CFDataRef.
                    s = [[NSString alloc] initWithData:(__bridge NSData *)model
                                                        encoding:NSASCIIStringEncoding];
//                    NSLog(@"Found GPU: %@", s);
                }
            }
            
                // Release the dictionary created by IORegistryEntryCreateCFProperties.
            CFRelease(serviceDictionary);
            
                // Release the serviceObject returned by IOIteratorNext.
            IOObjectRelease(serviceObject);
        }
        
            // Release the entry_iterator created by IOServiceGetMatchingServices.
        IOObjectRelease(entry_iterator);
        }
    return s;
}

+ (NSString*)getAudioDevices
{
    AudioObjectPropertyAddress propertyAddress = {
        kAudioHardwarePropertyDevices,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    UInt32 dataSize = 0;
    OSStatus status = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
    if(kAudioHardwareNoError != status)
        {
        NSLog(@"Unable to get number of audio devices. Error: %d",status);
        return NULL;
        }
    
    UInt32 deviceCount = dataSize / sizeof(AudioDeviceID);
    
    AudioDeviceID *audioDevices = malloc(dataSize);
    
    status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, audioDevices);
    if(kAudioHardwareNoError != status)
        {
        NSLog(@"AudioObjectGetPropertyData failed when getting device IDs. Error: %d",status);
        free(audioDevices), audioDevices = NULL;
        return NULL;
        }
    
    NSMutableArray* devices = [NSMutableArray array];
    
    for(UInt32 i = 0; i < deviceCount; i++)
        {
        
                // Query device name
            CFStringRef deviceName = NULL;
            dataSize = sizeof(deviceName);
            propertyAddress.mSelector = kAudioDevicePropertyDeviceNameCFString;
            status = AudioObjectGetPropertyData(audioDevices[i], &propertyAddress, 0, NULL, &dataSize, &deviceName);
            if(kAudioHardwareNoError != status) {
                fprintf(stderr, "AudioObjectGetPropertyData (kAudioDevicePropertyDeviceNameCFString) failed: %i\n", status);
                continue;
            }
        
            // Query device name
        CFStringRef deviceManufature = NULL;
        dataSize = sizeof(deviceManufature);
        propertyAddress.mSelector = kAudioDevicePropertyDeviceManufacturerCFString;
        status = AudioObjectGetPropertyData(audioDevices[i], &propertyAddress, 0, NULL, &dataSize, &deviceManufature);
        if(kAudioHardwareNoError != status) {
            fprintf(stderr, "AudioObjectGetPropertyData (kAudioDevicePropertyDeviceNameCFString) failed: %i\n", status);
            continue;
        }

        
                // Query device output volume
//            Float32 volume;
//            propertyAddress.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
//            status = AudioHardwareServiceHasProperty(audioDevices[i], &propertyAddress);
//            if(status) {
//                fprintf(stderr, "AudioObjectGetPropertyData (kAudioHardwareServiceDeviceProperty_VirtualMasterVolume) failed: %i\n", status);
//            } else {
//                dataSize = sizeof(volume);
//                status = AudioObjectGetPropertyData(audioDevices[i], &propertyAddress, 0, NULL, &dataSize, &volume);
//                if (status) {
//                        // handle error
//                }
//            }
        
//            NSLog(@"device found: %d - %@ || Vol: %f || status %i",audioDevices[i], deviceName, volume, status);  

//            NSLog(@"device found: %d: %@->%@  ",audioDevices[i], deviceManufature, deviceName);
        
            [devices addObject:[NSString stringWithFormat:@"%@[%@]",deviceManufature,deviceName]];
        }
    
    free(audioDevices);
    
    return [devices componentsJoinedByString:@", "];
}

+(void) getCpuDetails{
    struct cpusample sample1;
//    struct cpusample sample2;

//    struct cpusample delta;
    sample(&sample1);
    printSample(&sample1);
//    sleep(1);
//    sample(&sample2);
//    deltasample.totalSystemTime = sample2.totalSystemTime - sample1.totalSystemTime;
//    deltasample.totalUserTime = sample2.totalUserTime - sample1.totalUserTime;
//    deltasample.totalIdleTime = sample2.totalIdleTime - sample1.totalIdleTime;
//    
}

void printSample(struct cpusample *sample)
{
    uint64_t total = sample->totalSystemTime + sample->totalUserTime + sample->totalIdleTime;
    
    double onePercent = total/100.0f;
    
    NSLog(@"system: %f", (double)sample->totalSystemTime/(double)onePercent);
    NSLog(@"user: %f", (double)sample->totalUserTime/(double)onePercent);
    NSLog(@"idle: %f", (double)sample->totalIdleTime/(double)onePercent);
}


+ (void)getIPWithcompletionHandler:(void (^)(NSString *ipAddress)) responseHandler
{
    NSURL *iPURL = [NSURL URLWithString:@"http://ip-api.com/json"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:iPURL];
        //    [httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    [req setValue:@"text/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPMethod:@"GET"];
    req.timeoutInterval = 45;
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (nil != data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (dict) {
//                NSLog(@"Response: %@",dict);
                responseHandler([dict objectForKey:@"query"]);//Successfull case
            }
            else{
                
                responseHandler(nil);
            }
        }
        else{
            responseHandler(nil);
            
        }
    }];
    
}

+ (NSString *)getLocalIPAddress
{
    NSArray *ipAddresses = [[NSHost currentHost] addresses];
    NSArray *sortedIPAddresses = [ipAddresses sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    
    for (NSString *potentialIPAddress in sortedIPAddresses)
        {
        if ([potentialIPAddress isEqualToString:@"127.0.0.1"]) {
            continue;
        }
        
        NSArray *ipParts = [potentialIPAddress componentsSeparatedByString:@"."];
        
        BOOL isMatch = YES;
        
        for (NSString *ipPart in ipParts) {
            if (![numberFormatter numberFromString:ipPart]) {
                isMatch = NO;
                break;
            }
        }
        if (isMatch) {
            return potentialIPAddress;
        }
        }
    
        // No IP found
    return @"?.?.?.?";
}


/*
 static func systemLogs() -> [[String: String]] {
 let q = asl_new(UInt32(ASL_TYPE_QUERY))
 var logs = [[String: String]]()
 let r = asl_search(nil, q)
 var m = asl_next(r)
 while m != nil {
 var logDict = [String: String]()
 var i: UInt32 = 0
 while true {
 if let key = String.fromCString(asl_key(m, i)) {
 let val = String.fromCString(asl_get(m, key))
 logDict[key] = val
 i++
 } else {
 break
 }
 }
 m = asl_next(r)
 logs.append(logDict)
 }
 asl_release(r)
 return logs
 }
 */

-(NSArray*)console
{
    NSMutableArray *consoleLog = [NSMutableArray array];
    
    aslclient client = asl_open(NULL, NULL, ASL_OPT_STDERR);
    
    aslmsg query = asl_new(ASL_TYPE_QUERY);
    asl_set_query(query, ASL_KEY_MSG, NULL, ASL_QUERY_OP_NOT_EQUAL);
    aslresponse response = asl_search(client, query);
    
    asl_free(query);
    
    aslmsg message;
    while((message = asl_next(response)) != NULL)
        {
        const char *msg = asl_get(message, ASL_KEY_MSG);
        if (NULL != msg) {
            
            [consoleLog addObject:[NSString stringWithCString:msg encoding:NSUTF8StringEncoding]];
            
        }
        }
    if (message != NULL) {
        asl_free(message);
    }
    asl_free(response);
    asl_close(client);
    
    return consoleLog;
}


@end
