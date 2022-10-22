#pragma header

uniform float time = 0.0;

vec2 ShakeUV(vec2 uv, float time) {
    uv.x += 0.002 * sin(time*3.141) * sin(time*14.14);
    uv.y += 0.002 * sin(time*1.618) * sin(time*17.32);
    return uv;
}

void main() {
    gl_FragColor = texture2D(bitmap, ShakeUV(openfl_TextureCoordv, time / 2.0));
}