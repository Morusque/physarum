#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform vec2 resolution;
uniform sampler2D ppixels;
uniform float pheroDecay;

const vec4 bitEnc = vec4(1.,255.,65025.,16581375.);
const vec3 bitDec = 1./bitEnc.xyz;
vec3 floatToRGB (float v) {
    vec4 enc = bitEnc * v;
    enc = fract(enc);
    enc.xyz -= enc.yzw * 1./255;
    return enc.xyz;
}
float RGBToFloat (vec3 v) {
    return dot(v, bitDec);
}

float tanH(float x) {
	float e1 = exp(x);
	float e2 = exp(-x);
	return (e1-e2)/(e1+e2);
}

vec2 pixel = 1. / resolution;

void main( void ) {
	vec2 position = gl_FragCoord.xy * pixel;

	//float p0 = RGBToFloat(texture2D(ppixels, position).rgb);
	float p1 = RGBToFloat(texture2D(ppixels, mod(position+vec2(pixel.x,0),1)).rgb);
	float p2 = RGBToFloat(texture2D(ppixels, mod(position-vec2(pixel.x,0),1)).rgb);
	float p3 = RGBToFloat(texture2D(ppixels, mod(position+vec2(0,pixel.y),1)).rgb);
	float p4 = RGBToFloat(texture2D(ppixels, mod(position-vec2(0,pixel.y),1)).rgb);
	//float p5 = RGBToFloat(texture2D(ppixels, mod(position+vec2(pixel.x,-pixel.y),1)).rgb);
	//float p6 = RGBToFloat(texture2D(ppixels, mod(position-vec2(pixel.x,-pixel.y),1)).rgb);
	//float p7 = RGBToFloat(texture2D(ppixels, mod(position-pixel,1)).rgb);
	//float p8 = RGBToFloat(texture2D(ppixels, mod(position+pixel,1)).rgb);

	//float val = p0;
	float val = (p1+p2+p3+p4)*0.25;
	//float val = (p1+p2+p3+p4+p5+p6+p7+p8)*0.125;

	val = tanH(val*pheroDecay);
    
	gl_FragColor = vec4(floatToRGB(val),1);
}