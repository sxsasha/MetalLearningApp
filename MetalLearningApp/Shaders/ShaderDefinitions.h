//
//  ShaderDefinitions.h
//  MetalLearningApp
//
//  Created by sxsasha on 12/18/19.
//  Copyright © 2019 sxsasha. All rights reserved.
//
#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef enum {
    unused = 0,
    Sunlight = 1,
    Spotlight = 2,
    Pointlight = 3,
    Ambientlight = 4
} LightType;

typedef struct {
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
    LightType type;
} Light;

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
} FragmentUniforms;
