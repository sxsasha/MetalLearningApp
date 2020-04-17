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
    vector_float3 attenuation;
    vector_float3 coneDirection;
    float coneAngle;
    float intensity;
    float coneAttenuation;
    LightType type;
} Light;

typedef struct {
    vector_float3 cameraPosition;
    uint lightCount;
    uint tiling;
} FragmentUniforms;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2,
    Tangent = 3,
    Bitangent = 4
} Attributes;

typedef enum {
    VerticesIndex = 0,
    UniformsIndex = 11,
    LightsIndex = 12,
    FragmentUniformsIndex = 13
}  BufferIndices;

typedef enum {
    BaseColorTexture = 0,
    NormalTexture = 1
} Textures;
