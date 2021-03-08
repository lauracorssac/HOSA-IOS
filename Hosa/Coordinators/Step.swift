//
//  Step.swift
//  Hosa
//
//  Created by Laura Corssac on 10/27/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation

enum Step {
    
    //token list view
    case generateNewToken
    case seeDetails(String)
    
    //token generation
    case didFinishTokenGeneration(token: String)
    case close
    
    //token input
    case moreInformation
    
}
