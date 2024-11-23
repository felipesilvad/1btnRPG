extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		hold()
	
	if Input.is_action_just_released("ui_select"):
		print("do")

func hold():
	if Input.is_action_just_pressed("ui_select"):
		pass
	await get_tree().create_timer(5).timeout
