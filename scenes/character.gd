class_name Player
extends CharacterBody2D

@onready var hp_bar: ProgressBar = $Control/VBoxContainer/ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var side: int
var hold_time: float = 0.0
var is_holding: bool = false

signal moved_to_target
signal moved_back

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
