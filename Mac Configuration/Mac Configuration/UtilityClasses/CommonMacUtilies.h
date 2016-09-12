//
//  CommonMacUtilies.h
//  Mac Configuration
//
//  Created by Satendra Singh on 01/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMacUtilies : NSObject

+(vm_statistics_data_t)memoryStatus;

+(NSString *)videoCardInfo;

+ (NSString*)getAudioDevices;

+(void) getCpuDetails;

+ (void)getIPWithcompletionHandler:(void (^)(NSString *ipAddress)) responseHandler;


+ (NSString *)getLocalIPAddress;

@end
