import Foundation
import ARKit

class SceneManager: NSObject {
    
    weak var sceneView: ARSCNView?
    private var planes = [UUID: Plane]()
    
    func attach(to sceneView: ARSCNView) {
        self.sceneView = sceneView
        self.sceneView!.delegate = self
        configureSceneView(self.sceneView!)
    }
    
    private func configureSceneView(_ sceneView: ARSCNView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    func displayDegubInfo() {
        sceneView?.showsStatistics = true
        sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func addBox(pos: SCNVector3) {
        let box = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        node.position = pos
        sceneView?.scene.rootNode.addChildNode(node)
    }
    
    func addLine(_ start: SCNVector3, _ end: SCNVector3){
        //add line
        let line = SCNGeometry.line(from: start, to: end)
        let lineNode = SCNNode(geometry: line)
        lineNode.position = SCNVector3Zero
        sceneView?.scene.rootNode.addChildNode(lineNode)
        //        add value at middle of line
        let textNode = createTextNode(text: String(distance(start,end)*100)+" cm")
        textNode.position =  SCNVector3((start.x + end.x)/2, (start.y + end.y)/2, (start.z + end.z)/2)
        sceneView?.scene.rootNode.addChildNode(textNode)
    }
    
    func createTextNode(text: String) -> SCNNode {
        let text = SCNText(string: text, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.black
        let fontSize = Float(0.01)
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        //plane node as background
        let minVec = textNode.boundingBox.min
        let maxVec = textNode.boundingBox.max
        let bound = SCNVector3Make(maxVec.x - minVec.x,
                                   maxVec.y - minVec.y,
                                   maxVec.z - minVec.z);
        
        let plane = SCNPlane(width: CGFloat(bound.x + 1),
                             height: CGFloat(bound.y + 1))
        plane.cornerRadius = 0.2
        plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.9)
        plane.firstMaterial?.isDoubleSided = true
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(CGFloat( minVec.x) + CGFloat(bound.x) / 2 ,
                                        CGFloat( minVec.y) + CGFloat(bound.y) / 2,CGFloat(minVec.z - 0.01))
        
        textNode.addChildNode(planeNode)
        
        let constraint = SCNLookAtConstraint(target: sceneView?.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        textNode.pivot = SCNMatrix4MakeRotation(.pi, 0, 1, 0);

        
        return textNode
    }
    
    func distance(_ start:SCNVector3, _ end:SCNVector3) -> Float{
        let xDist = start.x - end.x
        let yDist = start.y - end.y
        let zDist = start.z - end.z
        let result = sqrt((xDist*xDist)+(yDist*yDist)+(zDist*zDist))
        return round(result*10000)/10000
    }
}

extension SceneManager: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // we only care about planes
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = Plane(anchor: planeAnchor)
        // store a local reference to the plane
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
}

extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
