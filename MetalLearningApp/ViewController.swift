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
    
    // Properties
    private var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configRender()
    }

    private func configRender() {
        renderer = Renderer(metalView: mtkView)
        
        let model = Model(name: "train")
        model.position = [0, 0.3, 0]
        model.rotation = [0, radians(fromDegrees: 45), 0]
        renderer?.models = [model]
        
        renderer?.camera.position = [0, 0, -5]
    }

}

