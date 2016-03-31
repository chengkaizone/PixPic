//
//  AuthorizationViewController.swift
//  P-effect
//
//  Created by anna on 1/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast
import ParseFacebookUtilsV4

final class AuthorizationViewController: UIViewController, StoryboardInitable, NavigationControllerAppearanceContext {
    
    static let storyboardName = Constants.Storyboard.Authorization
    
    private var router: protocol<FeedPresenter, AlertManagerDelegate>!
    private weak var locator: ServiceLocator!
    
    // MARK: - Lifecycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertManager.sharedInstance.registerAlertListener(router)
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setRouter(router: AuthorizationRouter) {
        self.router = router
    }
    
    // MARK: - Private methods
    private func signInWithFacebook() {
        let authService: AuthService = locator.getService()
        authService.signInWithFacebookInController(self) { [weak self] _, error in
            if let error = error {
                ErrorHandler.handle(error)
                self?.proceedWithoutAuthorization()
            } else {
                authService.signInWithPermission { _, error -> Void in
                    if let error = error {
                        ErrorHandler.handle(error)
                    } else {
                        PFInstallation.addPFUserToCurrentInstallation()
                    }
                }
                self?.view.hideToastActivity()
                self?.router.showFeed()
            }
        }
    }
    
    private func proceedWithoutAuthorization() {
        router.showFeed()
        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)
            
            return
        }
    }
    
    // MARK: - IBAction
    @IBAction private func logInWithFBButtonTapped() {
        view.makeToastActivity(CSToastPositionCenter)
        signInWithFacebook()
    }
    
}