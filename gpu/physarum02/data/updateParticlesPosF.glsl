#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER
#define PI 3.1415926535897932384626433832795
#define PI2 PI*2.0

uniform float mode;
uniform vec2 resolution;
uniform sampler2D dataAng;
uniform sampler2D ppixels;
uniform vec2 pheroRes;

uniform float speed;

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

vec2 pheroPixel = 1.0/pheroRes;
vec2 pixel = 1.0/resolution;

void main( void ) {
	vec2 position = gl_FragCoord.xy * pixel;

	vec4 pix = texture2D(ppixels, position);

	float val = RGBToFloat(pix.rgb);

	if (mode == 0) { //x
		float ang = RGBToFloat(texture2D(dataAng, position).rgb);
		pix.rgb = floatToRGB(mod(val+cos(ang*PI2)*pheroPixel.x*speed,1));
	} else {         //y
		float ang = RGBToFloat(texture2D(dataAng, position).rgb);
		pix.rgb = floatToRGB(mod(val+sin(ang*PI2)*pheroPixel.y*speed,1));
	}

	gl_FragColor = pix;
}