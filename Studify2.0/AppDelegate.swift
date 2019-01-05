//
//  AppDelegate.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 13/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import UIKit
import Firebase
import GoogleAPIClientForREST
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    
    // Service object for access to Classroom API
    private var service = GTLRClassroomService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeClassroomCourses,                            kGTLRAuthScopeClassroomCoursesReadonly, kGTLRAuthScopeClassroomCourseworkMe, kGTLRAuthScopeClassroomCourseworkMeReadonly,
            kGTLRAuthScopeClassroomCourseworkStudents, kGTLRAuthScopeClassroomCourseworkStudentsReadonly, kGTLRAuthScopeClassroomGuardianlinksMeReadonly, kGTLRAuthScopeClassroomGuardianlinksStudents, kGTLRAuthScopeClassroomGuardianlinksStudentsReadonly, kGTLRAuthScopeClassroomProfileEmails, kGTLRAuthScopeClassroomProfilePhotos, kGTLRAuthScopeClassroomPushNotifications, kGTLRAuthScopeClassroomRosters, kGTLRAuthScopeClassroomRostersReadonly, kGTLRAuthScopeClassroomStudentSubmissionsMeReadonly, kGTLRAuthScopeClassroomStudentSubmissionsStudentsReadonly]
        GIDSignIn.sharedInstance().delegate = self

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func listCourses(onCompleted: @escaping (GTLRClassroom_ListCoursesResponse?, Error?) -> ()) {
        // Check if we are authorized to make Classroom API calls
        if self.service.authorizer != nil {
            let query = GTLRClassroomQuery_CoursesList.query()
            query.pageSize = 10
            query.courseStates = ["ACTIVE"]
            
            self.service.executeQuery(query) { (ticket, results, error) in
                onCompleted(results as? GTLRClassroom_ListCoursesResponse, error)
            }
        }
    }
    
    func listTeacher(courseId : String, onCompleted: @escaping (GTLRClassroom_ListTeachersResponse?, Error?) -> ()) {
        if self.service.authorizer != nil {
            let teacherQuery = GTLRClassroomQuery_CoursesTeachersList.query(withCourseId: courseId)
            teacherQuery.pageSize = 10
            
            self.service.executeQuery(teacherQuery) { (ticket, results, error) in
                onCompleted(results as? GTLRClassroom_ListTeachersResponse, error)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        print("User Signed into Google")
        
        guard let authentication = user.authentication else { return }
        
        // Set the OAuth authorizer for the Classroom API
        service.authorizer = authentication.fetcherAuthorizer()
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            print("User is Signed into Firebase using Google Sign In")
            
            //let welcomeScreen = WelcomeScreenViewController()
            
            //welcomeScreen.performSegueToHomeworkScreen()
            if Auth.auth().currentUser != nil {
                let navigationController = self.window?.rootViewController as! UINavigationController
                for controller in navigationController.viewControllers {
                    if let LoginViewController = controller as? LogInViewContoller {
                        LoginViewController.performSegue(withIdentifier: "logInToHome", sender: nil)
                        break
                    }
                }
                
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //..
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

