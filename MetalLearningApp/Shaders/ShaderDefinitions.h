//
//  ShaderDefinitions.h
//  MetalLearningApp
//
//  Created by sxsasha on 12/18/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
} Uniforms;

#endif /* ShaderDefinitions_h */
