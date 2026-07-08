shader_type canvas_item;

group_uniforms Stacking;
uniform int stack_layers : hint_range(1, 64) = 16;
uniform vec2 stack_offset = vec2(2.0, 2.0);

group_uniforms Animation;
uniform bool animate = true;
uniform float skew_amount = 0.25;
uniform float skew_speed = 0.8;

uniform float depth_wobble = 1.0;
uniform float depth_speed = 0.6;

group_uniforms Outline;
uniform float outline_size : hint_range(0.0, 8.0) = 1.5;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Colors;
uniform vec4 front_top : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 front_bottom : source_color = vec4(0.75, 0.75, 0.75, 1.0);

uniform vec4 side_top : source_color = vec4(0.35, 0.35, 0.35, 1.0);
uniform vec4 side_bottom : source_color = vec4(0.05, 0.05, 0.05, 1.0);

void fragment() {
	vec2 uv = UV;

	vec2 animated_stack = stack_offset;
	float animated_skew_x = 0.0;
	float animated_skew_y = 0.0;

	if (animate) {
		animated_skew_x = sin(TIME * skew_speed) * skew_amount;
		animated_skew_y = cos(TIME * skew_speed * 0.7) * skew_amount * 0.35;

		animated_stack += vec2(
			sin(TIME * depth_speed),
			cos(TIME * depth_speed * 0.8)
		) * depth_wobble;
	}

	uv.x += (uv.y - 0.5) * animated_skew_x;
	uv.y += (uv.x - 0.5) * animated_skew_y;

	vec4 side = vec4(0.0);

	for (int i = stack_layers; i > 0; i--) {
		float depth = float(i) / float(stack_layers);

		vec2 stack_uv =
			uv - animated_stack * TEXTURE_PIXEL_SIZE * float(i);

		vec4 sample = texture(TEXTURE, stack_uv);

		vec4 gradient = mix(
			side_top,
			side_bottom,
			depth
		);

		gradient.rgb *= pow(1.0 - depth, 0.65);

		side.rgb = mix(
			side.rgb,
			gradient.rgb,
			sample.a
		);

		side.a = max(side.a, sample.a);
	}

	vec4 front = texture(TEXTURE, uv);

	vec4 front_gradient = mix(
		front_top,
		front_bottom,
		uv.y
	);

	front.rgb *= front_gradient.rgb;
	front.a *= front_gradient.a;

	float outline = 0.0;

	for (int ox = -1; ox <= 1; ox++) {
		for (int oy = -1; oy <= 1; oy++) {
			vec2 offset =
				vec2(float(ox), float(oy))
				* outline_size
				* TEXTURE_PIXEL_SIZE;

			outline = max(
				outline,
				texture(TEXTURE, uv + offset).a
			);

			for (int i = 1; i <= stack_layers; i++) {
				vec2 stack_uv =
					uv
					- animated_stack * TEXTURE_PIXEL_SIZE * float(i)
					+ offset;

				outline = max(
					outline,
					texture(TEXTURE, stack_uv).a
				);
			}
		}
	}

	vec4 result = mix(
		side,
		front,
		front.a
	);

	float outline_alpha = outline * (1.0 - result.a);

	result.rgb = mix(
		result.rgb,
		outline_color.rgb,
		outline_alpha
	);

	result.a = max(
		result.a,
		outline_alpha
	);

	COLOR = result;
}