extends Area2D
@export var speed: float = 450.0
@export var direction: Vector2 = Vector2.DOWN:
	set(val):
		direction = val
		update_hazard_visual()

enum HazardType { PENCIL, COIN, ERASER }
var hazard_type: HazardType = HazardType.PENCIL


func _ready() -> void:
	update_hazard_visual()


func update_hazard_visual() -> void:
	if abs(direction.y) > 0.9 and abs(direction.x) < 0.1:
		hazard_type = HazardType.PENCIL
		rotation = 0.0
	elif abs(direction.x) > 0.9 and abs(direction.y) < 0.1:
		hazard_type = HazardType.COIN
		rotation = 0.0
	else:
		hazard_type = HazardType.ERASER
		rotation = direction.angle() - PI / 2.0
	queue_redraw()



func _process(delta: float) -> void:
	position += direction * speed * delta
	if position.x < -80.0 or position.x > 1040.0 or position.y < -80.0 or position.y > 620.0:
		queue_free()
		return



	for body in get_overlapping_bodies():
		if body.has_signal("hit") and not body.get("is_crumb") and not body.get("is_dead"):
			body.hit.emit()
			break


func _on_screen_notifier_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_signal("hit") and not body.get("is_crumb") and not body.get("is_dead"):
		body.hit.emit()


func _draw() -> void:
	var outline_color = Color("514844") # Dark brown

	match hazard_type:
		HazardType.PENCIL:
			draw_rect(Rect2(-7, -10, 14, 20), Color("98D99B"))
			draw_rect(Rect2(-7, -10, 14, 20), outline_color, false, 1.8)
			draw_line(Vector2(0, -10), Vector2(0, 10), Color(0.32, 0.28, 0.27, 0.35), 1.0)
			draw_rect(Rect2(-7, -14, 14, 4), Color("F5F0E8"))
			draw_rect(Rect2(-7, -14, 14, 4), outline_color, false, 1.4)
			draw_rect(Rect2(-7, -19, 14, 5), Color("E99999"))
			draw_rect(Rect2(-7, -19, 14, 5), outline_color, false, 1.8)
			draw_colored_polygon(PackedVector2Array([Vector2(-7, 10), Vector2(7, 10), Vector2(0, 19)]), Color("E5DFAE"))
			draw_polyline(PackedVector2Array([Vector2(-7, 10), Vector2(0, 19), Vector2(7, 10)]), outline_color, 1.8)
			draw_colored_polygon(PackedVector2Array([Vector2(-3, 15), Vector2(3, 15), Vector2(0, 19)]), outline_color)

		HazardType.COIN:
			draw_circle(Vector2.ZERO, 17.0, Color("E5DFAE"))
			draw_arc(Vector2.ZERO, 17.0, 0, TAU, 32, outline_color, 2.2, true)
			draw_arc(Vector2.ZERO, 12.0, 0, TAU, 24, Color(0.32, 0.28, 0.27, 0.35), 1.2, true)
			draw_circle(Vector2.ZERO, 4.0, Color("E99999"))
			draw_circle(Vector2(0, -7), 2.2, Color("98D99B"))
			draw_circle(Vector2(0, 7), 2.2, Color("98D99B"))
			draw_circle(Vector2(-7, 0), 2.2, Color("98D99B"))
			draw_circle(Vector2(7, 0), 2.2, Color("98D99B"))

		HazardType.ERASER:
			draw_rect(Rect2(-9, -18, 18, 18), Color("A4A2DE"))
			draw_rect(Rect2(-9, 0, 18, 18), Color("8EB6DD"))
			draw_rect(Rect2(-10, -6, 20, 12), Color("F5F0E8"))
			draw_line(Vector2(-10, 0), Vector2(10, 0), Color("E99999"), 2.0)
			draw_rect(Rect2(-9, -18, 18, 36), outline_color, false, 2.0)
			draw_rect(Rect2(-10, -6, 20, 12), outline_color, false, 1.5)
