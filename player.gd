extends CharacterBody2D
@warning_ignore("unused_signal")
signal hit

@export var speed: float = 300.0
var screen_size:Vector2
const CRUMB_DURATION: float = 0.6
const CRUMB_COOLDOWN: float = 2.0

var is_crumb: bool = false
var can_crumb: bool = true
var is_dead: bool = false
var crumb_time_left: float = 0.0
var cooldown_time_left: float = 0.0
var walk_time: float = 0.0

func _ready() -> void:
	screen_size = get_viewport_rect().size


func _physics_process(delta: float) -> void:
	if is_crumb:
		crumb_time_left -= delta
		if crumb_time_left <= 0.0:
			end_crumb_mode()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not can_crumb:
		cooldown_time_left -= delta
		if cooldown_time_left <= 0.0:
			cooldown_time_left = 0.0
			can_crumb = true

	if Input.is_action_just_pressed("ui_accept") and can_crumb and not is_dead:
		start_crumb_mode()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	position.x = clamp(position.x, 16.0, screen_size.x - 16.0)
	position.y = clamp(position.y, 16.0, screen_size.y - 16.0)

	if velocity.length() > 10.0:
		walk_time += delta * 14.0
		queue_redraw()
	elif walk_time != 0.0:
		walk_time = 0.0
		queue_redraw()


func start_crumb_mode() -> void:
	is_crumb = true
	can_crumb = false
	crumb_time_left = CRUMB_DURATION
	scale = Vector2(1.5, 0.35)
	$CollisionShape2D.set_deferred("disabled", true)
	queue_redraw()


func end_crumb_mode() -> void:
	is_crumb = false
	can_crumb = false
	cooldown_time_left = CRUMB_COOLDOWN
	scale = Vector2(1.0, 1.0)
	$CollisionShape2D.set_deferred("disabled", false)
	queue_redraw()


func set_dead() -> void:
	is_dead = true
	is_crumb = false
	can_crumb = false
	scale = Vector2(2.2, 0.2)
	$CollisionShape2D.set_deferred("disabled", true)
	queue_redraw()


func _draw() -> void:
	var outline_color = Color("514844") 
	var body_color = Color("E999D9")    
	var feet_color = Color("E99999")    
	var blush_color = Color("E99999")   

	if is_dead:
		body_color = Color("E99999") 
	elif is_crumb:
		body_color = Color("E5DFAE") 


	var left_foot_y = 12.0
	var right_foot_y = 12.0
	if velocity.length() > 10.0 and not is_crumb and not is_dead:
		left_foot_y += sin(walk_time) * 2.0
		right_foot_y -= sin(walk_time) * 2.0

	
	draw_circle(Vector2(-7, left_foot_y), 4.0, feet_color)
	draw_arc(Vector2(-7, left_foot_y), 4.0, 0, TAU, 16, outline_color, 1.8, true)

	draw_circle(Vector2(7, right_foot_y), 4.0, feet_color)
	draw_arc(Vector2(7, right_foot_y), 4.0, 0, TAU, 16, outline_color, 1.8, true)


	draw_circle(Vector2.ZERO, 15.0, body_color)
	draw_arc(Vector2.ZERO, 15.0, 0, TAU, 32, outline_color, 2.4, true)


	if is_dead:

		draw_line(Vector2(-7, -4), Vector2(-3, 0), outline_color, 2.0)
		draw_line(Vector2(-7, 0), Vector2(-3, -4), outline_color, 2.0)
		draw_line(Vector2(3, -4), Vector2(7, 0), outline_color, 2.0)
		draw_line(Vector2(3, 0), Vector2(7, -4), outline_color, 2.0)
		draw_line(Vector2(-5, 4), Vector2(5, 4), outline_color, 1.8)
	elif is_crumb:

		draw_arc(Vector2(-5, 0), 3.0, PI + 0.3, TAU - 0.3, 10, outline_color, 1.8)
		draw_arc(Vector2(5, 0), 3.0, PI + 0.3, TAU - 0.3, 10, outline_color, 1.8)
		draw_circle(Vector2(-9, 2), 2.2, blush_color)
		draw_circle(Vector2(9, 2), 2.2, blush_color)
	else:

		draw_circle(Vector2(-5, -2), 2.4, outline_color)
		draw_circle(Vector2(5, -2), 2.4, outline_color)
		draw_circle(Vector2(-4.2, -3.0), 0.9, Color.WHITE)
		draw_circle(Vector2(5.8, -3.0), 0.9, Color.WHITE)
		draw_circle(Vector2(-9, 3), 2.2, blush_color)
		draw_circle(Vector2(9, 3), 2.2, blush_color)
		draw_arc(Vector2(0, 3), 2.5, 0.2, PI - 0.2, 12, outline_color, 1.6)
