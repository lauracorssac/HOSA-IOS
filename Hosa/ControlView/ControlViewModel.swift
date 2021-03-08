//
//  ControlViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/16/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

struct ItemTitle {
    let title: String
    
    lazy var mainTitle: String = {
        return "\(self.title) State"
    }()
    
    lazy var descriptionTitle: String = {
        return "\(self.title)"
    }()
}

final class ControlViewModel {
    
    let disposeBag = DisposeBag()
    var dataSource: [SecurityStatusSectionItem] = []
    
    let systemSensor = Topic(id: DataManager.systemSensorID, componentType: .sensor, port: DataManager.systemSensorPort) //system control
    let buzzerSensor =  Topic(id: DataManager.buzzerSensorID, componentType: .sensor, port: DataManager.buzzerSensorPort) //buzzer control
    
    let systemTitle = ItemTitle(title: "System")
    let alarmTitle = ItemTitle(title: "Alarm")
    
    private let shouldRefresh = BehaviorSubject<Bool>(value: true)
    
    lazy var cells: [ControlCellViewModel] = {
        return [
            ControlCellViewModel(item: systemSensor, shouldRefresh: self.shouldRefresh, itemTitle: systemTitle, controlShouldBeEnabled: self.controlShouldBeEnabled, server: ManagersManager.shared.communicationManager), //system control
            ControlCellViewModel(item: buzzerSensor, shouldRefresh: self.shouldRefresh, itemTitle: alarmTitle, controlShouldBeEnabled: self.controlShouldBeEnabled, server: ManagersManager.shared.communicationManager) //buzzer control
        ]
    }()
    
    let dangerStatusSubject = BehaviorSubject(value: DangerStatus.none)
    
    let controlShouldBeEnabled: BehaviorSubject<Bool>
    
    init() {
        
        controlShouldBeEnabled = BehaviorSubject<Bool>(value: true)
        
        let cellItems = cells.map { SecurityStatusSectionItem.statusControl(viewModel: $0 ) }
        
       // let raspStatusItem = SecurityStatusSectionItem.status(viewModel: StatusCellViewModel(raspberryIsEnable: self.controlShouldBeEnabled))
        let refreshViewModel = RefreshCellViewModel(title: "Refresh")
        let refreshItem = SecurityStatusSectionItem.refresh(viewModel: refreshViewModel )
        self.dataSource = cellItems + [refreshItem]
        
        refreshViewModel.refreshButtonPressed
            .map { _ in true }
            .bind(to: self.shouldRefresh)
            .disposed(by: disposeBag)
        
    }
    
}
