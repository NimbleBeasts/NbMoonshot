shader_type canvas_item;
uniform float scroll_spead = 0.1;

void fragment() {
	vec2 newuv = UV;
	newuv.x += TIME*scroll_spead;
	COLOR = texture(TEXTURE, newuv);
}