//
//  ViewController.swift
//  MetalLearningApp
//
//  Created by sxsasha on 12/4/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    // UI
    @IBOutlet private var mtkView: MTKView!
    
    var previousScale: CGFloat = 1
    
    // Properties
    private var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configRender()
        addGestureRecognizer()
    }

    private func configRender() {
        renderer = Renderer(metalView: mtkView)
        
        // first iteration
//        let train = Model(name: "train")
//        train.position = [0, 0.9, 0]
//        train.rotation = [0, radians(fromDegrees: 45), 0]
//
//        let treefir = Model(name: "treefir")
//        treefir.position = [1.4, 0, 0]
        
        // second iteration
//        let lowPolyHouse = Model(name: "lowpoly-house")
//        lowPolyHouse.position = [0, -1, 0]
//        lowPolyHouse.rotation = [0, radians(fromDegrees: 45), 0]
//
//        let plane = Model(name: "plane")
//        plane.tiling = 40
//        plane.position = [0, -1, 0]
//        plane.scale = [40, 40, 40]
        
        // third iteration
        let model = Model(name: "cottage2")
        model.position = [0, 0, 0]
        model.rotation = [0, radians(fromDegrees: 45), 0]
        
        renderer?.models = [model]
        renderer?.camera.position = [0, 2, -6]
    }
}

extension ViewController {
    private func addGestureRecognizer() {
      let pan = UIPanGestureRecognizer(target: self,
                                       action: #selector(handlePan(gesture:)))
      view.addGestureRecognizer(pan)
      
      let pinch = UIPinchGestureRecognizer(target: self,
                                           action: #selector(handlePinch(gesture:)))
      view.addGestureRecognizer(pinch)
    }
    
    @objc
    private func handlePan(gesture: UIPanGestureRecognizer) {
        let translationInView = gesture.translation(in: gesture.view)
        let translation = SIMD2<Float>(Float(translationInView.x),
                                       Float(translationInView.y))
        renderer?.camera.rotateUsing(translation: translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    @objc
    private func handlePinch(gesture: UIPinchGestureRecognizer) {
        let sensitivity: Float = 1.4
        renderer?.camera.zoomUsing(delta: gesture.scale - previousScale,
                                   sensitivity: sensitivity)
        
        previousScale = gesture.scale
        
        if gesture.state == .ended {
            previousScale = 1
        }
    }
}

