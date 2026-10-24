extends Node2D

func _draw() -> void:
	var dark_brown = Color("514844")
	var soft_coral = Color("E99999")
	var sky_blue = Color("8EB6DD")
	var lavender = Color("A4A2DE")

	# 1. Subtle desk mat / play area boundary (inset 16px from edges)
	draw_rect(Rect2(16, 16, 928, 508), Color(0.318, 0.282, 0.267, 0.16), false, 2.0)

	# 2. Notebook red/coral margin line (like stationery paper)
	draw_line(Vector2(68, 16), Vector2(68, 524), Color(0.914, 0.600, 0.600, 0.25), 1.5)

	# 3. Subtle ruler tick marks along top edge
	for x in range(30, 940, 20):
		var tick_h = 6.0 if (x % 100 == 0) else 3.0
		draw_line(Vector2(x, 16), Vector2(x, 16 + tick_h), Color(0.318, 0.282, 0.267, 0.2), 1.0)

	# 4. Cute pastel corner brackets (desk mat corners)
	var corners = [
		Vector2(24, 24),
		Vector2(936, 24),
		Vector2(24, 516),
		Vector2(936, 516)
	]
	for c in corners:
		draw_circle(c, 3.0, sky_blue)
		draw_arc(c, 3.0, 0, TAU, 16, dark_brown, 1.2, true)

	# 5. Tiny stationery tape / paper clip accent at top-right
	draw_line(Vector2(915, 20), Vector2(930, 20), lavender, 3.0)
	draw_line(Vector2(915, 25), Vector2(930, 25), soft_coral, 2.0)
