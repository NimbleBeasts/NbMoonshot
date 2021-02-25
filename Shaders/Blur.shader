shader_type canvas_item;

uniform float blur_amount : hint_range(0, 5);

void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
}