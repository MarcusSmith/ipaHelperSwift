//
//  main.swift
//  ipaHelper
//
//  Created by Marcus Smith on 4/10/15.
//  Copyright (c) 2015 ipaHelper. All rights reserved.
//

import Foundation

//let path = "/Users/msmith/Downloads/Enterprise_Wildcard_InHouse_Distribution_Profile.mobileprovision"
//
//if let profile = Profile(filePath: path) {
//    println()
//}
//else {
//    println()
//}

let libraryPath = "~/Library/MobileDevice/Provisioning Profiles/".stringByExpandingTildeInPath

libraryPath.lastPathComponent.pathExtension

let startTime = NSDate()

var profiles: [Profile] = []

if let libraryFiles = NSFileManager.defaultManager().contentsOfDirectoryAtPath(libraryPath, error: nil) as? [String] {
    let profileFiles = libraryFiles.filter({(filePath: String) -> (Bool) in
        if filePath.lastPathComponent.pathExtension == "mobileprovision" {
            return true
        }
    
        return false
    })
    
    for profileFile: AnyObject in profileFiles {
        if let profilePathComponent = profileFile as? String {
            let fullPath = libraryPath + "/" + profilePathComponent
            
            println("full path: \(fullPath)")
            
            if let profile = Profile(filePath: fullPath) {
                profiles.append(profile)
            }
        }
    }
}

let finishTime = NSDate()

let time = finishTime.timeIntervalSinceDate(startTime)

println("Decoded \(profiles.count) profiles!")
println("Time: \(time)")





