//
//  Profile.swift
//  ipaHelper
//
//  Created by Marcus Smith on 4/10/15.
//  Copyright (c) 2015 ipaHelper. All rights reserved.
//

import Cocoa
import Security

//==========================================================================
// MARK: Provisioning Profile
//==========================================================================

public class Profile {

    //==========================================================================
    // MARK: File Properties
    //==========================================================================
    
    public var filePath: String?
    public var filename: String? {
        return self.filePath?.lastPathComponent
    }
    
    //==========================================================================
    // MARK: Profile Properties
    //==========================================================================
    
    public let appIDName: String?
    public let applicationIdentifierPrefix: [String]
    public let developerCertificates: [NSData]
    public let entitlements: Entitlements!
    public let name: String?
    public let provisionsAllDevices: Bool
    public let provisionedDevices: [String]
    public let teamIdentifier: [String]
    public let teamName: String?
    public let timeToLive: Int
    public let uuid: String!
    public let version: Int
    
    public let creationDate: NSDate!
    public let expirationDate: NSDate!
    
    public var isExpired: Bool {
        return self.expirationDate.timeIntervalSinceNow < 0
    }
    
    public var isWildcard: Bool {
        return entitlements.applicationIdentifer.hasSuffix("*")
    }
    
    public var type: ProfileType {
        return .None
    }
    
    public func matches(bundleID: String) -> Bool {
        var appID = self.entitlements.applicationIdentifer
        
        if let dotRange = appID.rangeOfString(".") {
            appID.removeRange(appID.startIndex..<dotRange.endIndex)
        }
        
        if !isWildcard {
            return bundleID == appID
        }
        
        return bundleID.hasPrefix(appID.substringToIndex(appID.endIndex.predecessor())) || appID == "*"
    }
    
    //==========================================================================
    // MARK: Initializers
    //==========================================================================
    
    public init?(dictionary: [String: AnyObject]?) {
        
        self.creationDate = dictionary?[ProfilePropertyKey.creationDate.rawValue] as? NSDate
        self.expirationDate = dictionary?[ProfilePropertyKey.expirationDate.rawValue] as? NSDate
        
        self.appIDName = dictionary?[ProfilePropertyKey.appIDName.rawValue] as? String
        self.applicationIdentifierPrefix = dictionary?[ProfilePropertyKey.applicationIdentifierPrefix.rawValue] as? [String] ?? []
        self.developerCertificates = dictionary?[ProfilePropertyKey.developerCertificates.rawValue] as? [NSData] ?? []
        self.entitlements = Entitlements(dictionary: dictionary?[ProfilePropertyKey.entitlements.rawValue] as? [String: AnyObject])
        self.name = dictionary?[ProfilePropertyKey.name.rawValue] as? String
        self.provisionsAllDevices = dictionary?[ProfilePropertyKey.provisionsAllDevices.rawValue] as? Bool ?? false
        self.provisionedDevices = dictionary?[ProfilePropertyKey.provisionedDevices.rawValue] as? [String] ?? []
        self.teamIdentifier = dictionary?[ProfilePropertyKey.teamIdentifier.rawValue] as? [String] ?? []
        self.teamName = dictionary?[ProfilePropertyKey.teamName.rawValue] as? String
        self.timeToLive = dictionary?[ProfilePropertyKey.timeToLive.rawValue] as? Int ?? 0
        self.uuid = dictionary?[ProfilePropertyKey.UUID.rawValue] as? String
        self.version = dictionary?[ProfilePropertyKey.version.rawValue] as? Int ?? 0
        
        if (dictionary == nil || self.creationDate == nil || self.expirationDate == nil || self.entitlements == nil || self.uuid == nil) {
            return nil
        }
    }
    
    public convenience init?(filePath path: String?) {
        if let path = path {
            let dictionary = Profile.dictionary(contentsOfFile: path)
            
            self.init(dictionary: dictionary)
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
    
    //==========================================================================
    // MARK: Convenience Class Functions
    //==========================================================================
    
    private class func decode(fileData data: NSData) -> NSData? {
        var optionalDecoder: Unmanaged<CMSDecoderRef>? = nil
        CMSDecoderCreate(&optionalDecoder)
        
        if let decoderRef = optionalDecoder {
            let decoder = decoderRef.takeUnretainedValue()
            CMSDecoderUpdateMessage(decoder, data.bytes, Int(data.length))
            CMSDecoderFinalizeMessage(decoder)
            var optionalDataRef: Unmanaged<CFDataRef>? = nil
            CMSDecoderCopyContent(decoder, &optionalDataRef)
            
            if let dataRef = optionalDataRef {
                return dataRef.takeUnretainedValue() as NSData
            }
        }
        
        return nil
    }
    
    private class func dictionary(contentsOfFile path: String) -> [String: AnyObject]? {
        if let fileData = NSData(contentsOfFile: path) {
            if let data = Profile.decode(fileData: fileData) {
                return NSPropertyListSerialization.propertyListWithData(data, options: 0, format: nil, error: nil) as? [String: AnyObject]
            }
        }
        
        return nil
    }
}

//==========================================================================
// MARK: Entitlements
//==========================================================================

public class Entitlements {
    
    //==========================================================================
    // MARK: Properties
    //==========================================================================
    
    public let fullDictionary: [String: AnyObject]!
    
    // General
    public let applicationIdentifer: String!
    public let betaReportsActive: Bool
    public let getTaskAllow: Bool
    public let keychainAccessGroups: [String]
    public let teamIdentifier: String?
    
    // Push
    public let apsEnvironment: PushEnvironment
    
    // iCloud
    public let ubiquityStoreIdentifier: String?
    
    init?(dictionary: [String: AnyObject]?) {
        self.fullDictionary = dictionary
        
        // General
        self.applicationIdentifer = dictionary?[EntitlementsPropertyKey.applicationIdentifer.rawValue] as? String
        self.betaReportsActive = dictionary?[EntitlementsPropertyKey.betaReportsActive.rawValue] as? Bool ?? false
        self.getTaskAllow = dictionary?[EntitlementsPropertyKey.getTaskAllow.rawValue] as? Bool ?? false
        self.keychainAccessGroups = dictionary?[EntitlementsPropertyKey.keychainAccessGroups.rawValue] as? [String] ?? []
        self.teamIdentifier = dictionary?[EntitlementsPropertyKey.teamIdentifier.rawValue] as? String
        
        // Push
        self.apsEnvironment = PushEnvironment(rawValue: dictionary?[EntitlementsPropertyKey.apsEnvironment.rawValue] as? String ?? "") ?? .None
        
        // iCloud
        self.ubiquityStoreIdentifier = dictionary?[EntitlementsPropertyKey.ubiquityStoreIdentifier.rawValue] as? String
        
        if (self.fullDictionary == nil || self.applicationIdentifer == nil) {
            return nil
        }
    }
}

//==========================================================================
// MARK: Enums
//==========================================================================

public enum ProfileType {
    case None, Development, AdHocDistribution, AppStoreDistribution, Enterprise
}

public enum PushEnvironment: String {
    case None = ""
    case Development = "development"
    case Production =  "production"
}

//==========================================================================
// MARK: String Constants
//==========================================================================

private enum ProfilePropertyKey: String {
    case creationDate = "CreationDate"
    case expirationDate = "ExpirationDate"
    
    case appIDName = "AppIDName"
    case applicationIdentifierPrefix = "ApplicationIdentifierPrefix"
    case developerCertificates = "DeveloperCertificates"
    case entitlements = "Entitlements"
    case name = "Name"
    case provisionsAllDevices = "ProvisionsAllDevices"
    case provisionedDevices = "ProvisionedDevices"
    case teamIdentifier = "TeamIdentifier"
    case teamName = "TeamName"
    case timeToLive = "TimeToLive"
    case UUID = "UUID"
    case version = "Version"
}

private enum EntitlementsPropertyKey: String {
    // General
    case applicationIdentifer = "application-identifier"
    case betaReportsActive = "beta-reports-active"
    case getTaskAllow = "get-task-allow"
    case keychainAccessGroups = "keychain-access-groups"
    case teamIdentifier = "com.apple.developer.team-identifier"
    
    // Push
    case apsEnvironment = "aps-environment"
    
    // iCloud
    case ubiquityStoreIdentifier = "com.apple.developer.ubiquity-kvstore-identifier"
}
