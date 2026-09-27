## Public switchboard for Shady's shader backends.
##
## This is the pure shader compiler: it turns a subset of Nim into shader
## source. There is no runtime, window or image dependency.

import shady/backends/[shared, glsl, glsl3, glsl4, dx12, metal4, vulkan]

export shared, glsl, glsl3, glsl4, dx12, metal4, vulkan
