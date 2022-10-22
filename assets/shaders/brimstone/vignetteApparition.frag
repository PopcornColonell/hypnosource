#pragma header

#define PI 3.14159265
uniform float time = 0.0;
uniform float vignetteIntensity = 0.75;

void main() {
    float amount = (0.25 * sin(time * PI) + vignetteIntensity);
    vec4 color = texture2D(bitmap, openfl_TextureCoordv);
    float vignette = distance(openfl_TextureCoordv, vec2(0.5));
    vignette = mix(1.0, 1.0 - amount, vignette);
	gl_FragColor = vec4(mix(vec3(1.0, 0.0, 0.0), color.rgb, vignette), 1.0 - vignette);
}
     