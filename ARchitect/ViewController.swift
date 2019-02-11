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
    
    private var marker: [SCNVector3] = []
    private var lastNode: SCNVector3? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneManager.attach(to: sceneView)
        sceneManager.displayDegubInfo()
    }

    @IBAction func markPress(_ sender: UIButton) {
        if let currentNode = getNodeFromScene(){
            if let _ = lastNode{
                //valid last node then add box and pipe
                sceneManager.addBox(pos: currentNode)
                sceneManager.addPipe(lastNode!, currentNode)
                //assign to last node
                lastNode = currentNode
                marker.append(lastNode!)
            }
            else{
                //first node ever
                lastNode = currentNode
                marker.append(lastNode!)
                sceneManager.addBox(pos: lastNode!)
            }
        }
    }
    
 
    @IBAction func finishPress(_ sender: UIButton) {
        //add pipe between last and first node
        if (marker.count > 1){
            sceneManager.addPipe(lastNode!, marker[0])
            for node in marker{
                print(node)
            }
            //empty marker for new session
            marker = []
        }
    }
    
    
    @IBAction func clearPress(_ sender: UIButton) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if (node.geometry is SCNBox || node.geometry is SCNCylinder || node.geometry is SCNText){
                node.removeFromParentNode()
            }
        }
        //remove reference of lastNode 
        lastNode = nil
    }
    
    func getNodeFromScene() -> SCNVector3?{
        let planeHitTestResults = sceneView.hitTest(self.view.center, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first{
            let transform = result.worldTransform.columns.3
            return SCNVector3(transform.x,transform.y,transform.z)
        }
        return nil
    }
    

}
