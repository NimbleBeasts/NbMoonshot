shader_type canvas_item;

uniform float start_offset = 0.0;
uniform float strength = 0.1;

void fragment() {
	float t = TIME;
	vec2 uv = UV;
	uv.x += cos(t + start_offset * t) * strength / 100.0 * (1.0 - uv.y);
	vec4 img = texture(TEXTURE, uv);
	COLOR = img;
}