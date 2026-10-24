extends Node2D
@export var hazard_scene: PackedScene
var score: int = 0
static var high_score: int = 0
static var has_started_once: bool = false

var current_hazard_speed: float = 300.0
var max_hazard_speed: float = 500.0

var death_messages = [
	"DEV HAVE MERCY!",
	"DARE TRY AGAIN?",
	"YOU EARNED THAT",
	"WASTED!",
    "SKILL ISSUE =["
]

func _ready() -> void:
	$UI/HighScoreLabel.text = "Best: " + str(high_score)
	if has_started_once:
		$UI/TitleMenu.visible = false
		start_game()
	else:
		$UI/TitleMenu.visible = true
		$Player.set_physics_process(false)
func start_game() -> void:
	has_started_once = true
	$UI/TitleMenu.visible = false
	$Player.set_physics_process(true)
	$HazardTimer.start()
	$ScoreTimer.start()


func _process(_delta: float) -> void:
	update_crumb_hud()


func update_crumb_hud() -> void:
	if not has_node("Player") or not has_node("UI/CrumbLabel"):
		return

	if $Player.is_crumb:
		$UI/CrumbLabel.text = "CRUMBLING!"
		$UI/CrumbLabel.modulate = Color("B88B1E") 
		if has_node("UI/CrumbBar"):
			$UI/CrumbBar.value = 0.0
	elif not $Player.can_crumb:
		var time_str = "%.1f" % max($Player.cooldown_time_left, 0.0)
		$UI/CrumbLabel.text = "COOLDOWN: " + time_str + "s"
		$UI/CrumbLabel.modulate = Color("C95252") 
		if has_node("UI/CrumbBar"):
			$UI/CrumbBar.value = $Player.CRUMB_COOLDOWN - $Player.cooldown_time_left
	else:
		$UI/CrumbLabel.text = "CRUMB: READY"
		$UI/CrumbLabel.modulate = Color("439E4B") 
		if has_node("UI/CrumbBar"):
			$UI/CrumbBar.value = $Player.CRUMB_COOLDOWN



func _on_hazard_timer_timeout() -> void:
	var hazard = hazard_scene.instantiate()
	hazard.speed = current_hazard_speed

	var roll = randf()
	var spawn_pos = Vector2.ZERO
	var move_dir = Vector2.DOWN

	if roll < 0.35:
		spawn_pos = Vector2(randf_range(30.0, 930.0), -30.0)
		move_dir = Vector2.DOWN
	elif roll < 0.55:
		spawn_pos = Vector2(-30.0, randf_range(30.0, 510.0))
		move_dir = Vector2.RIGHT
	elif roll < 0.75:
		spawn_pos = Vector2(990.0, randf_range(30.0, 510.0))
		move_dir = Vector2.LEFT
	elif roll < 0.875:
		spawn_pos = Vector2(randf_range(30.0, 480.0), -30.0)
		move_dir = Vector2(1.0, 1.0).normalized()
	else:
		spawn_pos = Vector2(randf_range(480.0, 930.0), -30.0)
		move_dir = Vector2(-1.0, 1.0).normalized()

	hazard.position = spawn_pos
	hazard.direction = move_dir
	add_child(hazard)
	spawn_warning(spawn_pos, move_dir)


func spawn_warning(spawn_pos: Vector2, move_dir: Vector2) -> void:
	var edge_x = clampf(spawn_pos.x, 24.0, 936.0)
	var edge_y = clampf(spawn_pos.y, 24.0, 516.0)
	var marker = Node2D.new()
	marker.position = Vector2(edge_x, edge_y)
	add_child(marker)
	marker.draw.connect(func():
		var col = Color("E99999") # Soft coral
		var pts = PackedVector2Array([
			move_dir * 7.0,
			move_dir.orthogonal() * 4.0,
			-move_dir * 2.0,
			-move_dir.orthogonal() * 4.0
		])
		marker.draw_colored_polygon(pts, col)
		marker.draw_polyline(pts + PackedVector2Array([pts[0]]), Color("514844"), 1.4)
	)
	marker.queue_redraw()
	var tw = marker.create_tween()
	tw.tween_property(marker, "modulate:a", 0.0, 0.35)
	tw.tween_callback(marker.queue_free)


func _on_player_hit() -> void:
	if $Player.is_dead:
		return
	$Player.set_dead()
	$HazardTimer.stop()
	$Player.set_physics_process(false)
	$ScoreTimer.stop()


	var shake_tween = create_tween()
	for i in range(4):
		var offset = Vector2(randf_range(-5.0, 5.0), randf_range(-4.0, 4.0))
		shake_tween.tween_property(self, "position", offset, 0.035)
	shake_tween.tween_property(self, "position", Vector2.ZERO, 0.04)

	if score > high_score:
		high_score = score
	$UI/HighScoreLabel.text = "Best: " + str(high_score)
	$UI/GameOverMenu/GameOverLabel.text = death_messages.pick_random()
	$UI/GameOverMenu/FinalScoreLabel.text = "Final Score: " + str(score)


	$UI/GameOverMenu.scale = Vector2(0.85, 0.85)
	$UI/GameOverMenu.modulate.a = 0.0
	$UI/GameOverMenu.visible = true
	var menu_tween = create_tween().set_parallel(true)
	menu_tween.tween_property($UI/GameOverMenu, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	menu_tween.tween_property($UI/GameOverMenu, "modulate:a", 1.0, 0.18)

	print("Squished! Game Over.")




func _on_score_timer_timeout() -> void:
	score += 1
	$UI/ScoreLabel.text = "Score: " + str(score)
	if score % 10 == 0:
		current_hazard_speed = min(current_hazard_speed + 100.0, max_hazard_speed)
	if $HazardTimer.wait_time > 0.15:
		$HazardTimer.wait_time -= 0.015



func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_play_button_pressed() -> void:
	start_game()
