//
//  ViewController.swift
//  ARMagicBall
//
//  Created by Alex Rodrigues on 25/10/17.
//  Copyright © 2017 Alex Rodrigues. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private let HAT_IDENTIFIER = "hat"
    private let BALL_IDENTIFIER = "magic_ball"
    
    @IBAction func throwBall() {
        guard let ballNode = loadMagicBall() else { return }
        putBallOnCamera(ballNode: ballNode)
        applyGravityOn(ballNode: ballNode)
    }
    
    @IBAction func magic() {
        let nodes = sceneView.scene.rootNode.childNodes
        for node in nodes {
            if  let nodeName =  node.name {
                if nodeName == BALL_IDENTIFIER {
                    node.removeFromParentNode()
                }
            } else {
                node.removeFromParentNode()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
//        sceneView.debugOptions = [.showPhysicsShapes]
        placeHat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func placeHat() {
        guard let scene = SCNScene(named: "art.scnassets/magic.scn") else {
            return
        }
        sceneView.scene = scene
    }
    
    private func loadMagicBall() -> SCNNode? {
        guard let scene = SCNScene(named: "art.scnassets/ball.scn") else {
            return nil
        }
        return scene.rootNode.childNode(withName: BALL_IDENTIFIER, recursively: true)
    }
    
    private func putBallOnCamera(ballNode : SCNNode) {
        let camera = sceneView.session.currentFrame?.camera
        let cameraTransform = camera?.transform
        ballNode.simdTransform = cameraTransform!
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    private func applyGravityOn(ballNode : SCNNode) {
        let forceDirection = SCNVector3Make(0, -1, -2)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.applyForce(forceDirection, asImpulse: true)
        ballNode.physicsBody = physicsBody
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - ARSCNViewDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let _ = anchor as? ARPlaneAnchor else {
            return nil
        }
        
        guard let hatNode = sceneView.scene.rootNode.childNode(withName: HAT_IDENTIFIER, recursively: true) else { return nil }
        
        SCNTransaction.begin()
        hatNode.opacity = 1
        SCNTransaction.animationDuration = 2
        SCNTransaction.commit()
        
        return hatNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
}
