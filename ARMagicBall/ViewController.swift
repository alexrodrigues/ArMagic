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
    private let PLANE_IDENTIFIER = "plane"
    private let BALL_IDENTIFIER = "magic_ball"
    
    private var isBallsHidden = false
    
    @IBAction func throwBall() {
        guard let ballNode = loadMagicBall() else { return }
        putBallOnCamera(ballNode: ballNode)
        applyGravityOn(ballNode: ballNode)
    }
    
    @IBAction func magic() {
        // I know i am trying to fix this. I wonder if there is a way to find out if a SCNNode is inside another or the distance between is small. In my research's I not finding anything. Wait because the next review I will made this.
        isBallsHidden = !isBallsHidden
        guard let hat = sceneView.scene.rootNode.childNode(withName: HAT_IDENTIFIER, recursively: true) else { return }
        let nodes = sceneView.scene.rootNode.childNodes
        for node in nodes {
            if  node.position.length() > hat.position.length() && node.name != HAT_IDENTIFIER {
                changeOpacity(node: node, isHidden: isBallsHidden)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func placeHat() {
        guard let scene = SCNScene(named: "art.scnassets/magic.scn") else {
            return
        }
        sceneView.scene = scene
    }
    
    private func isInsideHat() {
        
    }
    
    private func loadMagicBall() -> SCNNode? {
        guard let scene = SCNScene(named: "art.scnassets/ball.scn") else {
            return nil
        }
        return scene.rootNode.childNode(withName: BALL_IDENTIFIER, recursively: true)
    }
    
    private func putBallOnCamera(ballNode : SCNNode) {
        guard let camera = sceneView.session.currentFrame?.camera else { return }
        ballNode.simdTransform = camera.transform
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    // Thank you 😊
    private func camera() -> (SCNVector3, SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let mat =  SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-2 * mat.m31, -2 * mat.m32, -2 * mat.m33)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    private func applyGravityOn(ballNode : SCNNode) {
        let forceDirection = camera().0
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.applyForce(forceDirection, asImpulse: true)
        ballNode.physicsBody = physicsBody
    }
    
    private func changeOpacity(node : SCNNode, isHidden : Bool) {
        var opacity = 0
        if !isHidden {
            opacity = 1
        }
        
        SCNTransaction.begin()
        node.opacity = CGFloat(opacity)
        SCNTransaction.animationDuration = 2
        SCNTransaction.commit()
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
        
        changeOpacity(node: hatNode, isHidden: false)
        
        return hatNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
}
