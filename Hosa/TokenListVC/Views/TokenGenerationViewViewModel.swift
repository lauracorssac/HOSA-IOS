//
//  TokenGenerationViewViewModel.swift
//  Hosa
//
//  Created by Laura Corssac on 11/3/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class TokenGenerationViewViewModel {
    
    let emptyStateTokens = Driver<String>.of("You don't have any valid token generated!")
    let informationString: Driver<NSAttributedString>
    let moreInfoButtonPressed = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(stepper: PublishSubject<Step>) {
        
        let infoString = NSMutableAttributedString(string: "By generating a token, you are able to invite other people to also have access to the security system your house. ")
        let knowMore = NSAttributedString(string: "Know More.", attributes: [NSAttributedString.Key.link: ""])
        infoString.append(knowMore)
        
        informationString = Driver<NSAttributedString>.of(infoString)
        
        moreInfoButtonPressed
            .map { _ in .moreInformation }
            .bind(to: stepper)
            .disposed(by: disposeBag)
    }
    
}
