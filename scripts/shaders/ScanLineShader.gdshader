shader_type canvas_item;

uniform float boarder = 10.0;
uniform float max_lines = 30.0;
uniform float darken_amount = 0.9; // Lower numbers the darker it is.
uniform float speed = 0.2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ivec2 size = textureSize(TEXTURE,0);
	float boarder_w = boarder / float(size.x);
	float boarder_h = boarder / float(size.y);

	float t1 = step(1.0 - boarder_w, UV.x);
	float t2 = 1.0 - step(boarder_w, UV.x);
	float t3 = step(1.0 - boarder_h, UV.y);
	float t4 = 1.0 - step(boarder_h, UV.y);

	float t = max(t1, max(t2, max(t3, t4)));
	t = 1.0 - t;
	float uv = -UV.y + TIME * speed;
	float interval = fract(uv * max_lines);
	float stepped = step(0.5,interval) * t;
	float mapped_value = mix(darken_amount,1.0,stepped);
	vec4 tex_color = texture(TEXTURE, UV) * mapped_value;
	COLOR = tex_color;
}