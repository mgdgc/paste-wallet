//
//  BackgroundTask.swift
//  paste-wallet
//
//  Created by 최명근 on 5/14/24.
//

import Foundation
import ActivityKit
import BackgroundTasks

class LiveActivityManager {
    enum BGTaskName: String {
        case cardKill = "com.mgchoi.paste-wallet.cardKill"
        case bankKill = "com.mgchoi.paste-wallet.bankKill"
        
        var identifier: String {
            return self.rawValue
        }
    }
    
    static let shared = LiveActivityManager()
    
    private let authorizationInfo: ActivityAuthorizationInfo
    private var authorized: Bool = false
    private var task: Task<Void, Never>?
    
    private init() { 
        // Initialize authorization info
        authorizationInfo = .init()
        // Initialize `authorized` which indicates whether the user has allowed live activity or not
        authorized = authorizationInfo.areActivitiesEnabled
        
        task = Task {
            // Keep tracking authorization status
            for await activityElement in authorizationInfo.activityEnablementUpdates {
                authorized = activityElement
            }
        }
    }
    
    deinit {
        task?.cancel()
    }
    
    var liveActivityExpiration: TimeInterval {
        return 60
    }
    
    @discardableResult
    func startCardLiveActivity(state: CardWidgetAttributes.ContentState, cardId: UUID) -> Activity<CardWidgetAttributes>? {
        // Check whether the user has authorized live activity or not
        guard authorized else {
            return nil
        }
        
        guard let terminationDate = startLiveActivityKillBackgroundTask(bgTaskName: .cardKill) else {
            return nil
        }
        
        let attribute = CardWidgetAttributes(id: cardId, createdAt: Date(), terminateAt: terminationDate)
        let content = ActivityContent(state: state, staleDate: .now.advanced(by: liveActivityExpiration))
        
        do {
            // Start Activity
            let activity = try Activity<CardWidgetAttributes>.request(
                attributes: attribute,
                content: content
            )
            
            return activity
        } catch {
            print(#function, error)
            return nil
        }
    }
    
    @discardableResult
    func startBankLiveActivity(state: BankWidgetAttributes.ContentState, bankId: UUID) -> Activity<BankWidgetAttributes>? {
        // Check whether the user has authorized live activity or not
        guard authorized else {
            return nil
        }
        
        guard let terminationDate = startLiveActivityKillBackgroundTask(bgTaskName: .bankKill) else {
            return nil
        }
        
        let attribute = BankWidgetAttributes(id: bankId, createdAt: Date(), terminateAt: terminationDate)
        let content = ActivityContent(state: state, staleDate: .now.advanced(by: liveActivityExpiration))
        
        do {
            // Start Activity
            let activity = try Activity<BankWidgetAttributes>.request(
                attributes: attribute,
                content: content
            )
            
            return activity
        } catch {
            print(#function, error)
            return nil
        }
    }
    
    func startLiveActivityKillBackgroundTask(bgTaskName: BGTaskName) -> Date? {
        let request = BGAppRefreshTaskRequest(identifier: bgTaskName.identifier)
        let terminationDate = Date(timeIntervalSinceNow: liveActivityExpiration)
        request.earliestBeginDate = terminationDate
        
        do {
            try BGTaskScheduler.shared.submit(request)
            return terminationDate
        } catch {
            print(error)
            return nil
        }
    }
    
    func killCardLiveActivities() async {
        for activity in Activity<CardWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
    
    func killBankLiveActivities() async {
        for activity in Activity<BankWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
