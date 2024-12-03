class_name Player
extends CharacterBody2D

@onready var hp_bar: ProgressBar = $Control/VBoxContainer/ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var side: int
var hold_time: float = 0.0
var is_holding: bool = false
var hit_by_special:Player
var original_position: Vector2
var moving: bool = false
var moving_back: bool = false
var attacking: bool = false
var active: bool = false
var on_spot: bool = true
var direction = Vector2(1,0).normalized()
@onready var main: Node2D = $"../../.."
@onready var sprite: Sprite2D = $Sprite2D
var main_sm: LimboHSM

func move_to_target(object, start:Vector2, end:Vector2, speed:float, signal_name:String):
	var tween = create_tween()
	tween.tween_property(object, "position", end, speed)
	await tween.finished
	emit_signal(signal_name)

func flip_sprite():
	if get_node("Sprite2D").flip_h == true:
		get_node("Sprite2D").flip_h = false
	else:
		get_node("Sprite2D").flip_h = true

func flash_white():
	sprite.modulate = Color(5, 5, 5, 1)  # Boost brightness to simulate a white flash
	await get_tree().create_timer(0.1).timeout  # Flash duration
	sprite.modulate = Color(1, 1, 1, 1)
	
func reset_position(delta, move_speed):
	if on_spot:
		main_sm.dispatch(&"to_idle")
	else:
		animation_player.play('move')
		if side == 1:
			get_node("Sprite2D").flip_h = true
		else:
			get_node("Sprite2D").flip_h = false
		
		if side == 1:
			position.x -= move_speed * delta
		else:
			position.x += move_speed * delta
		
	if position.distance_to(original_position) <= 2:
		position = original_position
		on_spot = true
		if side == 1:
			get_node("Sprite2D").flip_h = false
		else:
			get_node("Sprite2D").flip_h = true
			
		main_sm.dispatch(&"to_idle")
		if active:
			main.start_next_turn(1)
