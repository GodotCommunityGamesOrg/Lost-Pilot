shader_type canvas_item;
uniform vec4 bg_color : source_color; // Background color
uniform vec2 offset;                  // Offset for movement
uniform float bigStarSlow = 2.0;      // Parallax speed for big stars
uniform float mediumStarSlow = 6.0;   // Parallax speed for medium stars
uniform float smallStarSlow = 8.0;    // Parallax speed for small stars

uniform float smallStarAmount = 0.002; // Density of small stars
uniform float mediumStarAmount = 0.01; // Density of medium stars
uniform float bigStarAmount = 0.02;    // Density of big stars

uniform float pixelSize = 3.0;        // Size of star pixels (e.g., 1.0, 3.0, 5.0)

// Random number generator
float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 53758.5453123);
}

void fragment() {
	if (true){
	    vec2 normCoordBig = floor((FRAGCOORD.xy + offset / bigStarSlow) / pixelSize) * pixelSize;
	    vec2 normCoordMedium = floor((FRAGCOORD.xy + offset / mediumStarSlow) / pixelSize) * pixelSize;
	    vec2 normCoordSmall = floor((FRAGCOORD.xy + offset / smallStarSlow) / pixelSize) * pixelSize;

	    float color = 0.0;

	    // Draw medium stars
	    float size = 3.0 * pixelSize;
	    float prob = 1.0 - mediumStarAmount;
	    vec2 pos = floor(normCoordMedium / size);
	    float starValue = rand(pos);

	    if (starValue > prob) {
	        vec2 center = size * pos + vec2(size, size) * 0.5;
	        if (distance(normCoordMedium, center) < 0.5 * size) {
	            color += 1.0;
	        }
	    }

	     //Draw big stars
	    size = 10.0 * pixelSize;
	    prob = 1.0 - bigStarAmount;
	    pos = floor(normCoordBig / size);
	    starValue = rand(pos);

	    if (starValue > prob) {
			vec2 center = size * pos + vec2(size, size) * 0.5;
			float dist = distance(normCoordBig, center);
			float size = mix(7, 10, sin((TIME + (UV.x*UV.y)*5.0f) * 2.0) * 0.5 + 0.5);

			if (dist < size) {
		            color += 1.0;
		        }
	    }

	    // Draw small stars
	    if (rand(normCoordSmall / (20.0 * pixelSize)) > 1.0 - smallStarAmount) {
	        float r = rand(normCoordSmall);
	        color += r * (0.85 * sin(TIME * (r * 5.0) + 720.0 * r) + 0.95);
	    }

	    // Apply the pixel size
	    vec2 pixelCenter = floor(FRAGCOORD.xy / pixelSize) * pixelSize + pixelSize * 0.5;
	    if (distance(FRAGCOORD.xy, pixelCenter) > pixelSize * 0.5) {
	        color = 0.0;
	    }

	    // Combine color with the background
	    COLOR = vec4(vec3(color), color) + bg_color;
		if (COLOR == vec4(0,0,0,1)) {
			COLOR.a = 0.0;
		}
	}
	else {
		COLOR.a = 0.0;
	}
}
