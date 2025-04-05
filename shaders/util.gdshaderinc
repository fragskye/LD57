#ifndef UTIL
#define UTIL

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

float remap01(float x, float a_min, float a_max) {
	return (x - a_min) / (a_max - a_min);
}

float remap(float x, float a_min, float a_max, float b_min, float b_max) {
	return (x - a_min) / (a_max - a_min) * (b_max - b_min) + b_min;
}

float remap01_clamp(float x, float a_min, float a_max) {
	return clamp((x - a_min) / (a_max - a_min), 0.0, 1.0);
}

float remap_clamp(float x, float a_min, float a_max, float b_min, float b_max) {
	return clamp((x - a_min) / (a_max - a_min), 0.0, 1.0) * (b_max - b_min) + b_min;
}

// https://stackoverflow.com/a/17897228
// Licensed under WTFPL

vec3 rgb_to_hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#endif
