//
//  TokenGenerationInformationViewModel.swift
//  Hosa
//
//  Created by Laura Corssac on 11/3/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

class TokenGenerationInformationViewModel: InformationViewModel {
    
    let sectionList = BehaviorSubject<[TokenInformationSectionModel]>(value: [])
    
    init() {
        
        let firstText = """
            <p>A token is a key to enter the app. For other people to have access to Hosa's features, you first need a code for them. With this code, other people can:</p>

            <ul>
             <li>See a live stream of the place watched by the camera.</li>
             <li>Control the system</li>
             <li>Generate new tokens to invite more people to access the same!</li>
              
            </ul>
            <p></p>
            <p>The person for whom you sent the token may have access to one, two, or all the three features, depending on what you choose to allow in the next step! </p>
            <p>You may send the code generated to them as a link to the app: <p>
        """.stringFromHtml()
        
        let image = UIImage(named: "example.jpg")
        
        let middleText = """
            <p> In this case, they should only tap the link and, if it is a valid token, they are going to access the app automatically! </p>

            <p> Also, you can generate a QR code, which is a picture like the following </p>
        """.stringFromHtml()
        
        let qrCodeImage = UIImage(named: "qrCode.jpg")
        
        let bottomText = """
            <p> In this case, they should place your camera upon it and, if it is a valid token, they are going to access the app automatically! </p>

            <p> You will be able to delete the token generated at any time you want so that the people with it will not be able to access the app anymore. Also, you can generate as many tokens as you want! <p>

        """.stringFromHtml()
        
        sectionList.onNext([.section(title: "" , items: [.textCell(viewModel: firstText),
                                                         .imageCell(image: image),
                                                         .textCell(viewModel: middleText),
                                                         .imageCell(image: qrCodeImage),
                                                         .textCell(viewModel: bottomText)])])
        
    }
    
}
