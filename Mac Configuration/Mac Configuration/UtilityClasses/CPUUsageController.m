//
//  CPUUsageController.m
//  Mac Configuration
//
//  Created by Satendra Singh on 02/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

#import "CPUUsageController.h"

#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>

#include <sys/sysctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <net/route.h>

int PrintNetworkUsage () {
    @autoreleasepool {
       
        int mib[] = {
            CTL_NET,
            PF_ROUTE,
            0,
            0,
            NET_RT_IFLIST2,
            0
        };
        size_t len;
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
            fprintf(stderr, "sysctl: %s\n", strerror(errno));
            exit(1);
        }
        char *buf = (char *)malloc(len);
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
            fprintf(stderr, "sysctl: %s\n", strerror(errno));
            exit(1);
        }
        char *lim = buf + len;
        char *next = NULL;
        u_int64_t totalibytes = 0;
        u_int64_t totalobytes = 0;
        for (next = buf; next < lim; ) {
            struct if_msghdr *ifm = (struct if_msghdr *)next;
            next += ifm->ifm_msglen;
            if (ifm->ifm_type == RTM_IFINFO2) {
                struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
                totalibytes += if2m->ifm_data.ifi_ibytes;
                totalobytes += if2m->ifm_data.ifi_obytes;
            }
        }
        printf("total ibytes %qu\tobytes %qu\n", totalibytes, totalobytes);
        NSLog(@"%@:%@",[NSByteCountFormatter stringFromByteCount:totalibytes countStyle:NSByteCountFormatterCountStyleBinary],[NSByteCountFormatter stringFromByteCount:totalobytes countStyle:NSByteCountFormatterCountStyleBinary]);
    }
    return 0;
}


@implementation CPUUsageController

+(void)printNetwork{
    
    PrintNetworkUsage();
    
}

+(void)samplePrint{

    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0)
        {
        fprintf (stderr, "getting page size");
        }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS)
        {
        fprintf (stderr, "Failed to get VM statistics.");
        }
    
    double total = vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count;
    double wired = vmstat.wire_count / total;
    double active = vmstat.active_count / total;
    double inactive = vmstat.inactive_count / total;
    double free = vmstat.free_count / total;
    
    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
    
    double unit = 1024 * 1024;
    NSString *text = [NSString stringWithFormat: @"% 3.1f MB\n% 3.1f MB\n% 3.1f MB", vmstat.free_count * pagesize / unit, (vmstat.free_count + vmstat.inactive_count) * pagesize / unit, info.resident_size / unit];
    NSLog(text);
}

+ (void)currentCpuInfo
{
    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
    NSLock *CPUUsageLock;
    CPUUsageLock = [[NSLock alloc] init];

    
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    if(err == KERN_SUCCESS) {
        [CPUUsageLock lock];
        for(unsigned i = 0U; i < numCPUs; ++i) {
            float inUse, total;
            if(prevCpuInfo) {
                inUse = (
                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            NSLog(@"Core: %u Usage: %f",i,inUse / total);
        }
        [CPUUsageLock unlock];

        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    } else {
        NSLog(@"Error!");
    }
    
}


@end

