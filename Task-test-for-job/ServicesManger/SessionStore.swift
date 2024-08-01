//
//  SessionStore.swift
//  Task-test-for-job
//
//  Created by Apple on 31.7.2024.
//

import FirebaseAuth
import Combine
import UIKit

struct User {
    let uid: String
}

class SessionStore: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn = false

    var handle: AuthStateDidChangeListenerHandle?

    func listen() {
            handle = Auth.auth().addStateDidChangeListener { auth, firebaseUser in
                if let firebaseUser = firebaseUser {
                    self.user = User(uid: firebaseUser.uid)
                    self.isLoggedIn = true
                } else {
                    self.user = nil
                    self.isLoggedIn = false
                }
            }
        }

    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            completion(error)
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            completion(error)
        }
    }
    
    func loadCurrentUser(completion: @escaping (User?) -> Void) {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                let user = User(uid: "exampleUid")
                self.user = user
                DispatchQueue.main.async {
                    completion(user)
                }
            }
        }
    
    func signOut(from viewController: UIViewController) {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isLoggedIn = false
            
            // Переход к LoginViewController
            let loginVC = LoginViewController()
            if let navigationController = viewController.navigationController {
                navigationController.setViewControllers([loginVC], animated: true)
            } else {
                viewController.present(loginVC, animated: true, completion: nil)
            }
        } catch {
            print("Error signing out: \(error)")
        }
    }

}


