//
//  SceneCoordinator.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit
import RxSwift

class SceneCoordinator: SceneCoordinatorable {

    typealias FlowSceneCoordinator = FlowSceneCoordinatable & SceneCoordinatorable
    
    private weak var session: AppSession?
    fileprivate(set) var window: UIWindow
    
    func transition(to scene: SceneCompatible,
                    transition: SceneTransition = .root,
                    completion: SceneTransitionCompletion? = nil) {
        transition.transition(from: currentViewController,
                              to: scene.viewController(),
                              window: window,
                              completion: completion)
    }
    
    private var childCoordinators: [FlowSceneCoordinatable] = []
    private var isActiveSession: Bool {
        session?.sessionToken != nil
    }
    
    private let bag = DisposeBag()
        
    // MARK: - Init
    
    init(window: UIWindow,
         session: AppSession) {
        self.window = window
        self.session = session
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()
    }
    
    // MARK: - Start/finish
    
    func start() {
        let viewModel = SplashViewModel()
        self.transition(to: Scene.splash(viewModel))
        
//        if isActiveSession {
//            startMainFlow()
//        } else {
//            startSignInFlow()
//        }
        
        startMainFlow()
    }
    
    func finish() {
        childCoordinators = []
    }
    
    // MARK: - Flows
    
    private func startSignInFlow() {
        guard let session = self.session
        else {
            fatalError("Can't init sign in flow")
        }
        
        childCoordinators = []
        
        let finishCompletion: SceneTransitionCompletion = { [weak self] in
            self?.childCoordinators.removeAll(where: { $0 is SignInFlowCoordinatorable })
            self?.startMainFlow()
        }
        
        let coordinator = SignInFlowCoordinator(window: window,
                                                session: session,
                                                finishCompletion: finishCompletion)
        coordinator.start()
        
        childCoordinators.append(coordinator)
    }
    
    private func startMainFlow() {
        guard let session = self.session
        else {
            fatalError("Can't init sign in flow")
        }
        
        childCoordinators = []
        
        let finishCompletion: SceneTransitionCompletion = { [weak self] in
            self?.childCoordinators.removeAll(where: { $0 is MainFlowCoordinatable })
            self?.startSignInFlow()
        }
        
        let coordinator = MainFlowCoordinator(window: window,
                                              session: session,
                                              isActiveSession: true,
                                              finishCompletion: finishCompletion)
        coordinator.start()
        
        childCoordinators.append(coordinator)
    }
    
    func showError(error: Error?) {
        let closeAction: AlertViewModel.AlertAction = { [weak self] in
            //            self?.pop()
        }
        
        let viewModel = AlertViewModel(title: "Error",
                                       message: error?.localizedDescription,
                                       buttonTitle: "Ok",
                                       action: closeAction,
                                       showCheckmarkImage: false)
        
        transition(to: CommonScene.alert(viewModel),
                   transition: .modalInContext)
    }
    
    // MARK: - Drop down
    
    func showOptionsDropDown(with subject: PublishSubject<String>,
                             lastOptionSelectedTrigger: PublishSubject<Bool>? = nil,
                             options: [String],
                             selectedValue: String? = nil) {
        let viewModel = DropDownViewModel(options: options,
                                          coordinator: self,
                                          selectedValue: selectedValue)
        viewModel.selectedOptionObservable.bind(to: subject).disposed(by: bag)
        
        transition(to: CommonScene.dropDown(viewModel), transition: .modalInContext)
        
        if let lastOptionSelectedTrigger = lastOptionSelectedTrigger {
            subject
                .map({ $0 == options.last })
                .bind(to: lastOptionSelectedTrigger)
                .disposed(by: bag)
        }
    }
    
    // MARK: - Web view
    
    func showEmbeddedWebView(with url: URL) {
        let viewModel = EmbeddedWebViewViewModel(url: url)
        
        transition(to: CommonScene.webView(viewModel), transition: .modal)
    }
}

// MARK: - Pop transition

extension SceneCoordinator {
    
    func pop(toRoot: Bool = false,
             animated: Bool = false,
             completion: SceneTransitionCompletion? = nil) {
        
        let bag = self.bag
        
        executeOnMainThread {
            
            if let presenter = self.currentViewController?.actualViewController().presentingViewController {
                // dismiss a modal controller
                
                presenter.dismiss(animated: animated) {
                    completion?()
                }
            } else if let navigationController = self.currentViewController?.actualViewController().navigationController {
                // navigate up the stack
                // one-off subscription to be notified when pop complete
                _ = navigationController.rx.delegate
                    .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                    .map { _ in }
                    .subscribe(onCompleted: {
                        completion?()
                    })
                    .disposed(by: bag)
                
                if toRoot == true {
                    guard navigationController.popToRootViewController(animated: animated) != nil else {
                        fatalError("can't navigate back to root view controller from \(String(describing: self.currentViewController))")
                    }
                } else {
                    guard navigationController.popViewController(animated: animated) != nil else {
                        fatalError("can't navigate back from \(String(describing: self.currentViewController))")
                    }
                }
            } else {
                fatalError("Not a modal, no navigation controller: can't navigate back from \(String(describing: self.currentViewController))")
            }
        }
    }
}
