shader_type canvas_item;

uniform float hover: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform sampler2D gradient: filter_linear;

void fragment() {
	COLOR.rgb *= 1.0-hover*texture(gradient, UV).r;
}
