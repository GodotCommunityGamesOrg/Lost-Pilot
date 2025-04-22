shader_type canvas_item;

uniform float scanline_strength : hint_range(0.0, 1.0) = 0.2;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float speed = 1.0;

void fragment() {
    float time = TIME * speed;
    vec2 uv = UV;
    vec4 tex = texture(TEXTURE, uv);
	tex.a = COLOR.a;

    float scanline = sin(UV.y * 600.0) * scanline_strength;
    tex.rgb -= scanline;

    float glitch = step(0.95, fract(sin(dot(UV * time, vec2(12.9898, 78.233))) * 43758.5453));

    if (glitch > 0.0) {
        float offset = sin(UV.y * 50.0 + time * 10.0) * 0.01 * glitch_intensity;
        uv.x += offset;

        vec4 r = texture(TEXTURE, uv + vec2(0.003, 0.0));
        vec4 g = texture(TEXTURE, uv);
        vec4 b = texture(TEXTURE, uv - vec2(0.003, 0.0));
        tex.rgb = vec3(r.r, g.g, b.b);
    }

    COLOR = tex;
}
