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
        
        let model = Model(name: "train")
        model.position = [0, 0.3, 0]
        model.rotation = [0, radians(fromDegrees: 45), 0]
        renderer?.models = [model]
        
        renderer?.camera.position = [0, 0, -5]
        //renderer?.camera.fovDegree = 40
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

