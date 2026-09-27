# Nim to GPU shader language compiler.

Shady can compile a subset of Nim into `OpenGL Shader Language` (and HLSL /
Metal Shading Language) used by the GPU. This lets you test your shader code
with `echo` statements on the CPU and then compile the exact same code to a
GPU shader.

`nimble install shady`

![Github Actions](https://github.com/treeform/shady/workflows/Github%20Actions/badge.svg)

[API reference](https://treeform.github.io/shady)

This branch contains **only the shader compiler**. There is no window, image
or graphics runtime dependency: the compiler emits shader source strings.

Shady has two main goals:

* Write vertex and fragment/pixel shaders for games and 3d applications.
* Write compute shaders for offline processing and number crunching.

Currently supported shader types:

* Fragment/pixel shaders.
* Vertex shaders paired with fragment shaders for the traditional graphics pipeline.
* Compute shaders for GPU data processing.

Current shader targets:

* Desktop GLSL 4.10 via `glsl4Desktop` / `glslDesktop` for OpenGL 4.1+.
* Desktop GLSL 3.30 via `glsl3Desktop` for older desktop OpenGL.
* GLSL ES 3.0 via `glsl3WebGL` / `glslES3` for OpenGL ES 3.0 / WebGL 2.0.
* Vulkan GLSL 4.50 via `vulkanGlsl450`.
* HLSL via `hlslDX12` for DirectX 12.
* Metal Shading Language via `metalMSL`.

Use `toShader(shaderProc, target, stage)` for the general backend switch, or
`toGLSL`, `toHLSL`, and `toMSL` for language-specific helpers.

Shady uses:
* `vmath` library for vector and matrix operations.

# Using Shady as a shader generator:

Nim vertex shader:
```nim
proc basicVert(
  gl_Position: var Vec4,
  MVP: Uniform[Mat4],
  vCol: Vec3,
  vPos: Vec3,
  vertColor: var Vec3
) =
  gl_Position = MVP * vec4(vPos.x, vPos.y, 0.0, 1.0)
  vertColor = vCol
```

GLSL output:
```glsl
#version 410
precision highp float;

uniform mat4 MVP;
attribute vec3 vCol;
attribute vec3 vPos;
out vec3 vertColor;

void main() {
  gl_Position = MVP * vec4(vPos.x, vPos.y, 0.0, 1.0);
  vertColor = vCol;
}
```

Nim fragment shader:
```nim
proc basicFrag(fragColor: var Vec4, vertColor: Vec3) =
  fragColor = vec4(vertColor.x, vertColor.y, vertColor.z, 1.0)
```

GLSL output:
```glsl
#version 410
precision highp float;

in vec3 vertColor;

void main() {
  gl_FragColor = vec4(vertColor.x, vertColor.y, vertColor.z, 1.0);
}
```

The same Nim proc can also be executed on the CPU with plain Nim, which makes
it easy to test shader logic with `echo` and asserts before compiling it to a
GPU shader.

# Using Shady to write compute shaders:

Shady can be used to write compute shaders. Compute shaders allow more general
purpose code execution work in parallel and are often faster than the CPU for
this kind of workload.

```nim
# Setup the uniforms.
var inputCommandBuffer*: Uniform[SamplerBuffer]
var outputImageBuffer*: UniformWriteOnly[UImageBuffer]
var dimensions*: Uniform[IVec4] # ivec4(width, height, 0, 0)

# The shader itself.
proc commandsToImage() =
  var pos = gl_GlobalInvocationID
  for x in 0 ..< dimensions.x:
    pos.x = x.uint32
    let value = uint32(texelFetch(inputCommandBuffer, int32(pos.x)).x)
    #echo pos.x, " ", value
    let colorValue = uvec4(
      128,
      0,
      value,
      255
    )
    imageStore(outputImageBuffer, int32(pos.y * uint32(dimensions.x) + pos.x), colorValue)
```

Image-backed sampler types (`Sampler2d`, `ImageBuffer`, ...) are opaque on the
CPU, so shaders that use them still compile to GLSL/HLSL/MSL but their CPU
stubs return default values.
