#define PROCESSING_COLOR_SHADER

uniform float pheroDropped;

void main( void ) {
	gl_FragColor = vec4(1.,0.,0.,pheroDropped);
}