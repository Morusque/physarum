#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER
#define PI 3.1415926535897932384626433832795
#define PI2 PI*2.0

uniform vec2 resolution;
uniform sampler2D dataX;
uniform sampler2D dataY;
uniform sampler2D ppixels;
uniform sampler2D pheromones;
uniform vec2 pheroRes;

uniform float foresee;
uniform float particleFov;
uniform float rotAngle;

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

float myLerp( float p1, float p2, float n) {
	float d = p1-p2;
	if (abs(d)<0.5) { d = 0; }
	return mod(p1*(1-n) + (p2+sign(d)) * n,1);
}

vec2 pheroPixel = 1.0/pheroRes;
vec2 pixel = 1.0/resolution;

void main( void ) {
	vec2 dataPosition = gl_FragCoord.xy * pixel;

	float x = RGBToFloat(texture2D(dataX, dataPosition).rgb);
	float y = RGBToFloat(texture2D(dataY, dataPosition).rgb);

	vec4 pix = texture2D(ppixels, dataPosition);

	float prevAng = RGBToFloat(pix.rgb);
	vec2 prevPos = vec2(x,1-y); // y is inverted (??)

	// calculate 5 valeurs
	// move angle towards the higher value
	float newAng = prevAng;
	float angPi = newAng*PI2;
	vec2 dir = vec2(cos(angPi),-sin(angPi))*pheroPixel*foresee;
	float bestVal = RGBToFloat(texture2D(pheromones,prevPos + dir).rgb);
	float bestAng = newAng;

	for (int i = 1; i<3; i++) {
		newAng = mod(prevAng - i*particleFov,1);
		angPi = newAng * PI2;
		dir = vec2(cos(angPi),-sin(angPi))*pheroPixel*foresee;
		float val2 = RGBToFloat(texture2D(pheromones,prevPos + dir).rgb);
		if (val2 > bestVal) {
			bestAng = newAng;
			bestVal = val2;
		}
		newAng = mod(prevAng + i*particleFov,1);
		angPi = newAng * PI2;
		dir = vec2(cos(angPi),-sin(angPi))*pheroPixel*foresee;
		val2 = RGBToFloat(texture2D(pheromones,prevPos + dir).rgb);
		if (val2 > bestVal) {
			bestAng = newAng;
			bestVal = val2;
		}
	}

	float finalAng = myLerp(prevAng,bestAng,rotAngle);

	pix.rgb = floatToRGB(finalAng);

	gl_FragColor = pix;
}