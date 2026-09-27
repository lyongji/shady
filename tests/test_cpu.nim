import shady, vmath

block:
  proc cpuFragment(uv: Vec2, time: Uniform[float32], fragColor: var Vec4) =
    let pulse = 0.5'f32 + 0.5'f32 * sin(time)
    fragColor = vec4(uv.x, uv.y, pulse, 1.0)

  var color: Vec4
  cpuFragment(vec2(0.25, 0.75), 0.0'f32, color)
  doAssert abs(color.x - 0.25) < 0.0001
  doAssert abs(color.y - 0.75) < 0.0001
  doAssert abs(color.z - 0.5) < 0.0001
  doAssert color.w == 1.0

echo "CPU execution tests passed"
