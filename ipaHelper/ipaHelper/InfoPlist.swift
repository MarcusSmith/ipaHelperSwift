//
//  infoPlist.swift
//  ipaHelper
//
//  Created by Peter Buerer on 6/3/15.
//  Copyright (c) 2015 ipaHelper. All rights reserved.
//

import Cocoa

//==========================================================================
// MARK: Info Plist
//==========================================================================

public class InfoPlist {
    
    //==========================================================================
    // MARK: File Properties
    //==========================================================================
    
    public var filePath: String?
    public var filename: String? {
        return self.filePath?.lastPathComponent
    }
    
    //==========================================================================
    // MARK: Info Plist Properties
    //==========================================================================
    
//    public lazy var dictionary: [String: AnyObject]? = {
//        return [String: AnyObject]()
//    }()
//    
    public var bundleName: String?
    public var bundleDisplayName: String?
    public var bundleIdentifier: String?
    public var bundleVersion: String?
    public var shortBundleVersion: String?
    public var minimumOSVersion: Int
    public var supportedDevices: [String]
    
    //==========================================================================
    // MARK: Initializers
    //==========================================================================
    
    public init?(dictionary: [String: AnyObject]?) {
        
        self.bundleName = dictionary?[InfoPlistKey.bundleName.rawValue] as? String
        self.bundleDisplayName = dictionary?[InfoPlistKey.bundleDisplayName.rawValue] as? String
        self.bundleIdentifier = dictionary?[InfoPlistKey.bundleIdentifier.rawValue] as? String
        self.bundleVersion = dictionary?[InfoPlistKey.bundleVersion.rawValue] as? String ?? "0"
        self.shortBundleVersion = dictionary?[InfoPlistKey.shortBundleVersion.rawValue] as? String ?? "0"
        self.minimumOSVersion = dictionary?[InfoPlistKey.minimumOSVersion.rawValue] as? Int ?? 0
        self.supportedDevices = dictionary?[InfoPlistKey.supportedDevices.rawValue] as? [String] ?? []
        
        if (dictionary == nil || self.bundleName == nil) {
            return nil
        }
    }
    
    public convenience init?(filePath path: String?) {
        
        if let path = path {
            //make dictionary from file
            //call init with dictionary
            self.init(dictionary: [:])
        }
        else {
            self.init(dictionary: nil)
        }
        
        self.filePath = path
    }
    
    public convenience init?(fileURL url: NSURL) {
        let filePath = url.path
        
        self.init(filePath: filePath)
    }
}

private enum InfoPlistKey: String {
//    Things in infoplist
    case bundleName = "CFBundleName"
    case bundleDisplayName = "CFBundleDisplayName"
    case bundleIdentifier = "CFBundleIdentifier"
    case bundleVersion = "CFBundleVersion"
    case shortBundleVersion = "CFBundleShortBundleVersion"
    case minimumOSVersion = "MinimumOSVersion"
    case supportedDevices = "UIDeviceFamily"
}
