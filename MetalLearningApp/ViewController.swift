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
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configRender()
    }

    private func configRender() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU is not supported")
        }

        renderer = Renderer(device: device)

        mtkView.device = device
        mtkView.delegate = renderer
        mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
    }

}

