//
//  FaceIdRecognizedViewController.swift
//  NanoChallange2
//
//  Created by Hai on 19/09/19.
//  Copyright © 2019 Asep Abdaz. All rights reserved.
//

import UIKit
import LocalAuthentication

class FaceIdRecognizedViewController: UIViewController {
    
    @IBOutlet weak var typeRecognizedImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var recognizedTypeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        titleLabel.text = "Naah! Roaring Locked"
        messageLabel.text = "Unlock with Face ID to Open Roaring"
        check()
    }
    enum AuthenticationsState {
        case loggedin, loggedout
    }
    
    var context = LAContext()
    
    var state = AuthenticationsState.loggedout{
        didSet{
            state == .loggedin
            (state == .loggedin) || (context.biometryType != .faceID)
           
        }
    }
    
    @IBAction func tryAgainButton(_ sender: UIButton) {
        check()
    }
    
    func check() {
        
        if state == .loggedin {
            // logout saja
            state = .loggedout
        }else{
            context = LAContext()
            
            
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Log inb to your account"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            self.state = .loggedin
                            self.performSegue(withIdentifier: "sukses", sender: nil)
                        }
                    }else{
                        print(error?.localizedDescription ?? "Can't evaluate policy")
                    }
                }
            }
        }
        
    }
}
