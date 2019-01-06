//
//  CompetitionViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 03/01/2019.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class CompetitionViewController: UIViewController, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        
    }
    
    
    @IBOutlet weak var competitionView: UIView!
    
    @IBAction func openLeaderboardGameCenter(_ sender: Any) {
    }
    
    var numberOfHomeworkAssignmentsCompleted = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        competitionView.layer.cornerRadius = 10
        
        //CHANGE THIS LATER
        numberOfHomeworkAssignmentsCompleted = 5
        
        authenticatePlayerGameCenter()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func authenticatePlayerGameCenter(){
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil{
                self.present(view!, animated: true, completion: nil)
            }
            else{
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
            
        }
    }
    
    func saveNumberOfHomeworkAssignmentsCompleted( number : Int){
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
        }
        
    }
}
