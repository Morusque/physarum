#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 resolution;

const vec3 bitDec = 1./vec3(1.,255.,65025.);
float RGBToFloat (vec3 v) {
    return dot(v, bitDec);
}

vec2 pixel = 1.0/resolution;

void main( void ) {
	vec2 position = gl_FragCoord.xy * pixel;
	float col = RGBToFloat(texture2D(texture,position).rgb)*3;
	gl_FragColor = vec4(0,0,col,1);
}