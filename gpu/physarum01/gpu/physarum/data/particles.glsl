
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PI 3.1415926535897932384626433832795

varying vec4 vertTexCoord;

uniform sampler2D previousPixels;
uniform sampler2D field;
uniform vec2 resolution;
uniform float foresee;
uniform float angleLerp;
uniform float speed;
uniform int width;
uniform int height;
uniform float floatingPrecision;

float colorToFloat(vec4 color) {
    return (float(color.r) + float(color.g) * 256.0 + float(color.b) * 256.0 * 256.0) * 255.0 / floatingPrecision;
}

vec4 floatToColor(float f) {
    vec4 color;
	f *= floatingPrecision;
	color.a = 255.0;
	color.b = floor((f) / (256.0 * 256.0));
	color.g = floor((f - float(color.b) * 256.0 * 256.0) / (256.0));
	color.r = floor((f - float(color.b) * 256.0 * 256.0 - float(color.g) * 256.0));
	return color / 255.0;
}

float czm_luminance(vec3 rgb) {
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}

void main() {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec2 pixel = 1./resolution;
	
	float value;

	vec2 xTPos = vec2(vertTexCoord.x, 1.0f/6.0f);
	vec2 yTPos = vec2(vertTexCoord.x, 3.0f/6.0f);
	vec2 aTPos = vec2(vertTexCoord.x, 5.0f/6.0f);
	float x = colorToFloat(texture2D(previousPixels, xTPos).rgba);
	float y = colorToFloat(texture2D(previousPixels, yTPos).rgba);
	float a = colorToFloat(texture2D(previousPixels, aTPos).rgba);
	
	if (vertTexCoord.y >= 0.0f/3.0f && vertTexCoord.y < 1.0f/3.0f) {// position x
		value = x;
		value += cos(a) * speed;
		value = mod(value+width,width);
	}
	if (vertTexCoord.y >= 1.0f/3.0f && vertTexCoord.y < 2.0f/3.0f) {// position y
		value = y;
		value += sin(a) * speed;
		value = mod(value+height,height);
	}
	if (vertTexCoord.y >= 2.0f/3.0f && vertTexCoord.y < 3.0f/3.0f) {// position a
		float newAngle = a;
		float bestSpot = -1;
		float range = 1.0;
		int nbProbes = 5;
		for (int i=0; i<nbProbes; i++) {
		  float aD = -range + float(i)*(range*2.0)/(float(nbProbes)-1);
		  vec2 projectedPos = vec2(mod(x+cos(a+aD)*foresee+float(width),float(width))/float(width), mod(y+sin(a+aD)*foresee+float(height),float(height))/float(height));
		  float thisPheromonal = czm_luminance(texture2D(field, projectedPos.xy).rgb);
		  if (thisPheromonal>bestSpot) {
			bestSpot = thisPheromonal;
			newAngle = a + aD;
		  }
		}
		newAngle = a*(1.0-angleLerp)+newAngle*angleLerp;
		
		value = newAngle;
		
	}
	
	gl_FragColor = floatToColor(value);
		
}
