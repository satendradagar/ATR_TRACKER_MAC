//
//  MemoryProfiller.swift
//  Mac Configuration
//
//  Created by Satendra Singh on 01/09/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation
import Cocoa



class SystemEventLogger {



static func getConsoleLogForAnHour() -> [String]? {
    
        let query = ASLQueryObject()
    let option = ASLQueryObject.Operation.keyExists
        query.setQueryKey(ASLAttributeKey.message, value: nil, operation: ASLQueryObject.Operation.keyExists, modifiers:ASLQueryObject.OperationModifiers.none)
        query.setQueryKey(ASLAttributeKey.level, value: ASLPriorityLevel.warning.priorityString, operation: ASLQueryObject.Operation.lessThanOrEqualTo, modifiers: ASLQueryObject.OperationModifiers.none)
        query.setQueryKey(ASLAttributeKey.time, value: Int(NSDate().timeIntervalSince1970 - (60 * 5)), operation: ASLQueryObject.Operation.greaterThanOrEqualTo, modifiers: ASLQueryObject.OperationModifiers.none)
        let client = ASLClient()
        
        client.search(query) { record in
            if let record = record {
                print(record.timestamp.descriptionWithLocale(NSLocale.currentLocale()) + ":::::" + record.message)
                // we have a search query result record; process it here
            } else {
                // there are no more records to process; no further callbacks will be issued
            }
            return true   // returning true to indicate we want more results if available
        }
    return nil;
    }
}