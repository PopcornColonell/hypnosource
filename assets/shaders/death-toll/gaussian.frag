//source: https://www.shadertoy.com/view/fsV3R3

#pragma header

uniform float iTime;

vec2 iResolution = openfl_TextureSize;

uniform float amount = 0.5;

const float pi = radians(180.);
const int samples = 20;
const float sigma = float(samples) * 0.25;

// we don't need to recalculate these every time
const float sigma2 = 2. * sigma * sigma;
const float pisigma2 = pi * sigma2;

float gaussian(vec2 i) {
    float top = exp(-((i.x * i.x) + (i.y * i.y)) / sigma2);
    float bot = pisigma2;
    return top / bot;
}

vec3 blur(sampler2D sp, vec2 uv, vec2 scale) {
    vec2 offset;
    float weight = gaussian(offset);
    vec3 col = texture2D(sp, uv).rgb * weight;
    float accum = weight * amount;
    
    // we need to use x <= samples / 2
    // to ensure symmetry
    for (int x = 0; x <= samples / 2; ++x) {
        for (int y = 1; y <= samples / 2; ++y) {
            offset = vec2(x, y);
            weight = gaussian(offset);
            col += texture2D(sp, uv + scale * offset).rgb * weight;
            accum += weight;

            // since values are symmetrical
            // we can re-use the "weight" value, saving 3 function calls

            col += texture2D(sp, uv - scale * offset).rgb * weight;
            accum += weight;

            offset = vec2(-y, x);
            col += texture2D(sp, uv + scale * offset).rgb * weight;
            accum += weight;

            col += texture2D(sp, uv - scale * offset).rgb * weight;
            accum += weight;
        }
    }
    
    return col / accum;
}

void main() {
    vec2 fragCoord = openfl_TextureCoordv * iResolution;

    vec2 ps = vec2(1.0) / iResolution.xy;
    vec2 uv = fragCoord * ps;

    gl_FragColor = vec4(blur(bitmap, uv, ps * amount), texture2D(bitmap,uv).a);
}