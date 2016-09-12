//
//  DataLogger.swift
//  Mac Configuration
//
//  Created by Satendra Singh on 31/08/16.
//  Copyright © 2016 Satendra Singh. All rights reserved.
//

import Foundation
import Cocoa

class DataLogger {
    
    static func logMessage(let label:String , message:String ) -> Void {
        let delegate: AppDelegate = NSApp.delegate as! AppDelegate
        let printableStr = "\(label): \(message)\n"
        print(printableStr);
        delegate.mainTextView.append(printableStr)
        delegate.mainTextView.append("---------------------------------------------------------------------------------------------\n\n")
    }
    
}

extension NSTextView {
    func append(string: String) {
        self.textStorage?.appendAttributedString(NSAttributedString(string: string))
        self.scrollToEndOfDocument(nil)
    }
}