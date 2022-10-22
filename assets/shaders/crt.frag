#pragma header

/**
* Source: https://www.shadertoy.com/view/wllBDM
*/
uniform float time = 1.0;

float scanSpeedAdd = 1.0;
float lineCut = 0.1;
float whiteIntensity = 0.8;
float anaglyphIntensity = 0.5;

// Anaglyph colors.
vec3 col_r = vec3(0.0, 1.0, 1.0);
vec3 col_l = vec3(1.0, 0.0, 0.0);

void main() {
    // Normalized pixel coordinates (from 0 to 1).
    vec2 uv = openfl_TextureCoordv;
    vec2 uv_right = vec2(uv.x + 0.01, uv.y + 0.01);
    vec2 uv_left = vec2(uv.x - 0.01, uv.y - 0.01);

    // Black screen.
    vec3 col = vec3(0.0);
    
    // Measure speed.
    float scanSpeed = (fract(time) * 2.5 / 40.0) * scanSpeedAdd;
    
    // Generate scanlines.
    vec3 scanlines = vec3(1.0) * abs(cos((uv.y + scanSpeed) * 100.0)) - lineCut;
    
    // Generate anaglyph scanlines.
    vec3 scanlines_right = col_r * abs(cos((uv_right.y + scanSpeed) * 100.0)) - lineCut;
    vec3 scanlines_left = col_l * abs(cos((uv_left.y + scanSpeed) * 100.0)) - lineCut;
    
    col = smoothstep(0.1, 0.7, scanlines * whiteIntensity) + smoothstep(0.1, 0.7, scanlines_right * anaglyphIntensity) + smoothstep(0.1, 0.7, scanlines_left * anaglyphIntensity);
    
    vec2 eyefishuv = (uv - 0.5) * 2.5;
    float deform = (1.0 - eyefishuv.y*eyefishuv.y) * 0.02 * eyefishuv.x;
    vec4 texture1 = texture2D(bitmap, vec2(uv.x - deform*0.95, uv.y));
    
    float bottomRight = pow(uv.x, uv.y * 100.0);
    float bottomLeft = pow(1.0 - uv.x, uv.y * 100.0);
    float topRight = pow(uv.x, (1.0 - uv.y) * 100.0);
    float topLeft = pow(uv.y, uv.x * 100.0);
    
    float screenForm = bottomRight + bottomLeft + topRight + topLeft;

    vec3 col2 = 1.0-vec3(screenForm);

    gl_FragColor = texture1 + vec4((smoothstep(0.1, 0.9, col) * 0.1), 1.0);
    gl_FragColor = vec4(gl_FragColor.rgb * col2, gl_FragColor.a);
}