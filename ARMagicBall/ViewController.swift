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
    private let HAT_BASE_IDENTIFIER = "hat_base"
    private let HAT_TOP_IDENTIFIER = "hat_top"
    private let HAT_WITH_FLOOR_IDENTIFIER = "hat_with_floor"
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
        guard let hat = sceneView.scene.rootNode.childNode(withName: HAT_IDENTIFIER, recursively: true) else { return }
        let hatWorldPosition = hat.worldPosition
        
        let (tubeMin, tubeMax): (SCNVector3, SCNVector3) = hat.boundingBox

        
        let minX = hatWorldPosition.x + tubeMin.x
        let minY = hatWorldPosition.y + tubeMin.y
        let minZ = hatWorldPosition.z + tubeMin.z
        
        let maxX = hatWorldPosition.x + tubeMax.x
        let maxY = hatWorldPosition.y + tubeMax.y
        let maxZ = hatWorldPosition.z + tubeMax.z
        
        for ball in balls {
            let pos = ball.presentation.worldPosition
            print("x-> \(pos.x)   y-> \(pos.y)   z-> \(pos.z)")
            let isInsideHat = ((pos.x >= minX && pos.y >= minY && pos.z >= minZ) && (pos.x <= maxX && pos.y <= maxY && pos.z <= maxZ))
            // because the floor is inside the hat node
            let isOutsideHat = (pos.z < -1.0)
            if isInsideHat && !isOutsideHat {
                ball.isHidden = !ball.isHidden
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
    
    private func isOnTheFloor() {
        // trabalhar com o width e o height do floor para excluir o mesmo do hat node
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

