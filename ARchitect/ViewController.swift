//
//  ViewController.swift
//  ARchitect
//
//  Created by macOS on 12/29/18.
//  Copyright © 2018 nam. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let sceneManager = SceneManager()
    private var tapCount = 0
    private var start: SCNVector3? = nil
    private var end: SCNVector3? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneManager.attach(to: sceneView)
        sceneManager.displayDegubInfo()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchTapped(_:)))
        self.view.addGestureRecognizer(tap)
    }


    @objc func touchTapped(_ sender: UITapGestureRecognizer) {
//        let tapPosition = sender.location(in: self.view)
        if (tapCount == 0){
            tapCount += 1
            let planeHitTestResults = sceneView.hitTest(self.view.center, types: .existingPlaneUsingExtent)
            if let result = planeHitTestResults.first{
                let transform = result.worldTransform.columns.3
                start = SCNVector3(transform.x,transform.y,transform.z)
                sceneManager.addBox(pos: start!)
            }
        }
        else{
            tapCount = 0;
            let planeHitTestResults = sceneView.hitTest(self.view.center, types: .existingPlaneUsingExtent)
            if let result = planeHitTestResults.first{
                let transform = result.worldTransform.columns.3
                end = SCNVector3(transform.x,transform.y,transform.z)
                sceneManager.addBox(pos: end!)
                sceneManager.addLine(start!, end!)
            }
        }
    }


}
