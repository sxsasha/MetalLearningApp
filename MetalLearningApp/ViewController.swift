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

        let plane = Model(name: "plane")
        plane.tiling = 40
        plane.position = [0, 0, 0]
        plane.scale = [40, 40, 40]
        
        let cottage = Model(name: "cottage1")
        cottage.position = [0, 0, 0]
        cottage.scale = [1.5, 1.5, 1.5]
        cottage.rotation = [0, radians(fromDegrees: 45), 0]
        
        let cube = Model(name: "cube")
        cube.position = [0, 0.5, 0]
        cube.scale = [0.5, 0.5, 0.5]
        cube.rotation = [0, 0, 0]
        
//        let rose = Model(name: "rose")
//        rose.position = [7, 0, 0]
//        rose.scale = [0.5, 0.5, 0.5]
//        rose.rotation = [0, 0, 0]
//
//        let flower = Model(name: "chrystanthemum_flower")
//        flower.position = [10, 0, 0]
//        flower.rotation = [0, 0, 0]
//        flower.scale = [0.5, 0.5, 0.5]
        
        renderer?.models = [plane, cube]
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

