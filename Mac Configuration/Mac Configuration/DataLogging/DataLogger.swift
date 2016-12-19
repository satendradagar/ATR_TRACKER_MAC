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
    static var dict = [String:String]()
    
    static func logMessage(let label:String , message:String ) -> Void {
//        let delegate: AppDelegate = NSApp.delegate as! AppDelegate
        let printableStr = "\(label): \(message)\n"
        dict[label] = message
        
//        print(printableStr);
//        delegate.mainTextView.append(printableStr)
//        delegate.mainTextView.append("---------------------------------------------------------------------------------------------\n\n")
    }
    
    static func logDictionary() -> [String:String] {
        
        return dict
    }

}


extension NSTextView {
    func append(string: String) {
        self.textStorage?.appendAttributedString(NSAttributedString(string: string))
        self.scrollToEndOfDocument(nil)
    }
}
