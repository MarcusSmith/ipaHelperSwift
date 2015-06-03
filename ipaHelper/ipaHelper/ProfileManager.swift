//
//  ProfileManager.swift
//  ipaHelper
//
//  Created by Marcus Smith on 6/3/15.
//  Copyright (c) 2015 ipaHelper. All rights reserved.
//

import Foundation

public class ProfileManager {
    
    //==========================================================================
    // MARK: Library
    //==========================================================================
    
    public static let library = ProfileManager(directoryPath: "~/Library/MobileDevice/Provisioning Profiles/".stringByExpandingTildeInPath)
    
    //==========================================================================
    // MARK: General
    //==========================================================================
    
    public var directoryPath: String
    
    init(directoryPath: String) {
        self.directoryPath = directoryPath
    }
    
    //==========================================================================
    // MARK: Profile Caching
    //==========================================================================
    
    public var profiles: [Profile] {
        if _profiles == nil {
            updateProfiles()
        }
        if let profiles = _profiles {
            return profiles
        }
        
        return []
    }
    
    private var _profiles: [Profile]?
    
    //==========================================================================
    // MARK: Filtered Profiles
    //==========================================================================
    
    public var expiredProfiles: [Profile] {
        return profiles.filter({ $0.isExpired})
    }
    
    public func profilesMatching(bundleID: String, profileType: ProfileType? = nil, acceptWildcardMatches: Bool = false) -> [Profile] {

        var matches = profiles.filter({ $0.matches(bundleID) })
        
        if !acceptWildcardMatches {
            matches = matches.filter({ !$0.isWildcard })
        }
        
        if let type = profileType {
            matches = matches.filter({ $0.type == type })
        }
        
        return matches
    }
    
    //==========================================================================
    // MARK: Profile Updating
    //==========================================================================
    
    public func updateProfiles() {
        _profiles = getProfiles()
    }
    
    private func getProfiles() -> [Profile] {
        var profiles: [Profile] = []
        
        if let libraryFiles = NSFileManager.defaultManager().contentsOfDirectoryAtPath(directoryPath, error: nil) as? [String] {
            let profileFiles = libraryFiles.filter({(filePath: String) -> (Bool) in
                if filePath.lastPathComponent.pathExtension == "mobileprovision" {
                    return true
                }
                
                return false
            })
            
            for profileFile: AnyObject in profileFiles {
                if let profilePathComponent = profileFile as? String {
                    let fullPath = directoryPath + "/" + profilePathComponent
                    
                    if let profile = Profile(filePath: fullPath) {
                        profiles.append(profile)
                    }
                }
            }
        }
        
        return profiles
    }
}



