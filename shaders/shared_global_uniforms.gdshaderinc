#ifndef SHARED_GLOBAL_UNIFORMS
#define SHARED_GLOBAL_UNIFORMS

global uniform float texel_density;
global uniform float inv_texel_density;

global uniform sampler2D value_noise_texture : filter_nearest, repeat_enable;
global uniform float value_noise_texture_size;

#endif