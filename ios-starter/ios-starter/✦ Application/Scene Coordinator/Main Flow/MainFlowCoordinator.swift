//
//  MainFlowCoordinator.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

final class MainFlowCoordinator: SceneCoordinator, FlowSceneCoordinatable {
    
    private weak var _session: AppSession?
    internal var finishCompletion: SceneTransitionCompletion
    
    override func start() {
        showMain()
    }
    
    override func finish() {
        finishCompletion()
    }
    
    // MARK: - Init
    
    init(window: UIWindow,
         session: AppSession,
         isActiveSession: Bool = false,
         finishCompletion: @escaping SceneTransitionCompletion) {
        self.finishCompletion = finishCompletion
        self._session = session
        
        super.init(window: window,
                   session: session,
                   isActiveSession: isActiveSession)
    }
}

extension MainFlowCoordinator: MainFlowCoordinatable {
    
    var session: AppSession {
        guard let session = self._session
        else {
            fatalError("MainFlowCoordinator. Can't get app session")
        }
        return session
    }
    
    // MARK: - MainFlowCoordinatable
    
    func showMain() {
        let restBackend = session.appRESTBackend
        let viewModel = MainViewModel(restBackend: restBackend)

        self.transition(to: Scene.dashboard(viewModel),
                        transition: .root)
    }
    
    func showTabBarMain() {
        let restBackend = session.appRESTBackend
        let mainViewModel = MainViewModel(restBackend: restBackend)
        let settingsViewModel = SettingsViewModel()

        self.transition(to: Scene.tabBarDashboard(mainViewModel, settingsViewModel),
                        transition: .root)
    }
    
    func showError(error: Error) {
        super.showError(error: error)
    }
}
