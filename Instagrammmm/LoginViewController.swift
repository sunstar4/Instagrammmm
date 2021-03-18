//
//  LoginViewController.swift
//  Instagrammmm
//
//  Created by Shy Shy on 3/13/21.
//

import UIKit
import Parse


class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        // Do any additional setup after loading the view.
        passwordTextField.isSecureTextEntry = true
        userNameTextField.delegate = self
        passwordTextField.delegate = self
    
    }
    
    
    @IBAction func OnSignIn(_ sender: Any) {
        let username = userNameTextField.text!
        let password = passwordTextField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) {
            (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Wrong password")
            }
        }
    }
    
    @IBAction func OnSignUp(_ sender: Any) {
          let user = PFUser()
            user.username = userNameTextField.text
            user.password = passwordTextField.text
    
            user.signUpInBackground { (success, error) in
                if success {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                } else {
                    print("Error:\(error!.localizedDescription)")
                }
            }
        }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
           /*
         let user = PFUser()
            user.username = userNameTextField.text
            user.password = passwordTextField.text
            
         user.signUpInBackground {
                (succeeded: Bool, error: Error?) -> Void in
                if let error = error {
                    _ = error.localizedDescription
                  // Show the errorString somewhere and let the user try again.
                } else {
                  // Hooray! Let them use the app now.
            
                }
            } */
    }
  
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



