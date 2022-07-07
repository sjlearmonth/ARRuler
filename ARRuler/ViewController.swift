//
//  ViewController.swift
//  ARRuler
//
//  Created by Stephen Learmonth on 07/07/2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    private func addDot(at hitResult: ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    private func calculate() {
        
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2.0) + pow(b, 2.0) + pow(c, 2.0))
        
        updateText(text: String(distance), atPosition: end.position)
        
        renderDashedLine(for: distance)
    }
    
    private func updateText(text: String, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white

        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(0.001, 0.001, 0.001)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    
    }
    
    private func renderDashedLine(for distance: Float) {
        
        let numberOfDashes = distance / 0.02
        let spaceDistance = 0.01
        
        let wholeNumberOfDashes = floor(numberOfDashes)
        let fractionofDash = numberOfDashes - wholeNumberOfDashes
        var dashNodes = [SCNNode]()
        
        for dash in 0..<Int(wholeNumberOfDashes) {
            let dashGeometry = SCNBox(width: 0.004, height: 0.004, length: 0.02, chamferRadius: 0.0)
            let dashMaterial = SCNMaterial()
            dashMaterial.diffuse.contents = UIColor.white
            dashGeometry.materials = [dashMaterial]
            let dashNode = SCNNode(geometry: dashGeometry)
            var dashNodeX = dotNodes[0].position.x + dashNode.position.x * Float(dash)
            var dashNodeY = dotNodes[0].position.y + dashNode.position.y * Float(dash)
            var dashNodeZ = dotNodes[0].position.z + dashNode.position.z * Float(dash)
            if dash > 0 {
                dashNodeX += Float(dash) * 0.01
                dashNodeY += Float(dash) * 0.004
                dashNodeZ += Float(dash) * 0.004
            }
            dashNode.position = SCNVector3(dashNodeX, dashNodeY, dashNodeZ)
            dashNodes.append(dashNode)
        }
        
        let lengthOfFractionalDash = CGFloat(distance - wholeNumberOfDashes * 0.02)
        let fractionalDashGeometry = SCNBox(width: 0.004, height: 0.004, length: lengthOfFractionalDash, chamferRadius: 0.0)
        let fractionalDashMaterial = SCNMaterial()
        fractionalDashMaterial.diffuse.contents = UIColor.white
        fractionalDashGeometry.materials = [fractionalDashMaterial]
        let fractionalDashNode = SCNNode(geometry: fractionalDashGeometry)
        dashNodes.append(fractionalDashNode)
    }
}
