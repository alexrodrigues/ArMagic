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
        isBallsHidden = !isBallsHidden
        
        let nodes = sceneView.scene.rootNode.childNodes
        for node in nodes {
            if  let nodeName =  node.name {
                if nodeName == BALL_IDENTIFIER {
                    changeOpacity(node: node, isHidden: isBallsHidden)
                }
            } else {
                changeOpacity(node: node, isHidden: isBallsHidden)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.debugOptions = [.showPhysicsShapes]
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
        /*
            Hello mr reviewer. When I set the simdTransform of the ballNode am I setting the rotation too? I can't find on stackoverflow the solution of get the user's camera rotation, please can you give more details to help me?
        */
        guard let camera = sceneView.session.currentFrame?.camera else { return }
        
        
        /*!
         @abstract Determines the receiver's transform. Animatable.
         @discussion The transform is the combination of the position, rotation and scale defined below. So when the transform is set, the receiver's position, rotation and scale are changed to match the new transform.
         
         
            @available(iOS 11.0, *)
            open var simdTransform: simd_float4x4
         
         */

        ballNode.simdTransform = camera.transform
        
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    private func applyGravityOn(ballNode : SCNNode) {
        let forceDirection = SCNVector3Make(0, -1, -2)
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
        
        changeOpacity(node: hatNode, isHidden: false)
        
        return hatNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
}
