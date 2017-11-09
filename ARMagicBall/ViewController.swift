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
    private let HAT_TUBE_IDENTIFIER = "hat_tube"
    private let PLANE_IDENTIFIER = "plane"
    private let BALL_IDENTIFIER = "magic_ball"
    
    private var balls = [SCNNode]()
    
    @IBAction func throwBall() {
        guard let ballNode = loadMagicBall() else { return }
        putBallOnCamera(ballNode: ballNode)
        applyGravityOn(ballNode: ballNode)
        balls.append(ballNode)
    }
    
    @IBAction func magic() {
        // Thanks for the help. I am having trouble to check if a SCNVector3 is inside the range of another. Can you explaining more how can I get that information of a SCNVector3? The SCNVector3 doc is very poor!
        guard let hatTube = sceneView.scene.rootNode.childNode(withName: HAT_TUBE_IDENTIFIER, recursively: true) else { return }
        
        
        let (boxMin, boxMax): (SCNVector3, SCNVector3) = hatTube.boundingBox
        let min = hatTube.worldPosition + boxMin
        let max = hatTube.worldPosition  + boxMax
        
        print("max: x - \(max.x) y - \(max.y) z - \(max.z)")
        print("min: x - \(min.x) y - \(min.y) z - \(min.z)")
        
        for ball in balls {
            if (ball.position.x >= min.x && ball.position.y >= min.y && ball.position.z >= min.z) &&
                (ball.position.x <= max.x && ball.position.y <= max.y && ball.position.z <= max.z) {
                print("ball: x - \(ball.position.x) y - \(ball.position.y) z - \(ball.position.z)")
                ball.isHidden = !ball.isHidden
            } else {
                print("failed")
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

