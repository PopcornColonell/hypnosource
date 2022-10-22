#pragma header

#define PI 3.14159265
uniform float time = 0.0;
uniform float intensity = 0.0;
uniform float initial = 0.0;

float sat( float t ) {
	return clamp( t, 0.0, 1.0 );
}

vec2 sat( vec2 t ) {
	return clamp( t, 0.0, 1.0 );
}

vec3 spectrum_offset( float t ) {
    float t0 = 3.0 * t - 1.5;
	return clamp( vec3( -t0, 1.0-abs(t0), t0), 0.0, 1.0);
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    float ofs = (initial / 1000) + (intensity / 1000);

	vec4 sum = vec4(0.0);
	vec3 wsum = vec3(0.0);
    const int samples = 4;
    const float sampleinverse = 1.0 / float(samples);
	for( int i=0; i<samples; ++i )
	{
        float t = float(i) * sampleinverse;
		uv.x = sat( uv.x + ofs * t );
		vec4 samplecol = texture2D( bitmap, uv, -10.0 );
		vec3 s = spectrum_offset( t );
		samplecol.rgb = samplecol.rgb * s;
		sum += samplecol;
		wsum += s;
    }
	sum.rgb /= wsum;
	sum.a *= sampleinverse;
    
	gl_FragColor.a = sum.a;
	gl_FragColor.rgb = sum.rgb; 
}