//
//  main.swift
//  ipaHelper
//
//  Created by Marcus Smith on 4/10/15.
//  Copyright (c) 2015 ipaHelper. All rights reserved.
//

import Foundation

let startTime = NSDate()

//var profiles = ProfileManager.library.profilesMatching("de.bmw.co2", acceptWildcardMatches: false)
var profiles = ProfileManager.library.expiredProfiles

let finishTime = NSDate()

let time = finishTime.timeIntervalSinceDate(startTime)

println("Found \(profiles.count) matching profiles")
println("Time: \(time)")

for profile in profiles {
    println("\(profile.filePath)")
}




