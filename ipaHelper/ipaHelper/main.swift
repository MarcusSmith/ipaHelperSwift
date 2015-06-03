//
//  main.swift
//  ipaHelper
//
//  Created by Marcus Smith on 4/10/15.
//  Copyright (c) 2015 ipaHelper. All rights reserved.
//

import Foundation

println("Hello, World!")

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

println("Time: \(NSDate())")

var profiles: [Profile] = []

if let libraryFiles = NSFileManager.defaultManager().contentsOfDirectoryAtPath(libraryPath, error: nil) as? [String] {
    let profileFiles = libraryFiles.filter({(file: String) -> (Bool) in
        if let url = file as? NSURL {
            if let path = url.path {
                if path.lastPathComponent.pathExtension == "mobileprovision" {
                    return true
                }
            }
        }
    
        return false
    })
    
    for profilefile: AnyObject in profileFiles {
        if let fileUrl = profilefile as? NSURL {
            if let profile = Profile(fileURL: fileUrl) {
                profiles.append(profile)
            }
        }
    }
}

println("Decoded \(profiles.count) profiles!")
println("Time: \(NSDate())")





