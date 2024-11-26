class_name Player
extends CharacterBody2D

@onready var hp_bar: ProgressBar = $Control/VBoxContainer/ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var hitbox_scene:PackedScene = preload("res://scenes/hitbox.tscn")
var side: int
var hold_time: float = 0.0
var is_holding: bool = false
var hp: int = 100

const THRESHOLDS = [
	{"hold": "", "action": "short_press_action", "value": 0.1, "color": Color.LIGHT_GRAY},
	{"hold": "first_long_hold", "action": "first_long_press_action", "value": 0.75, "color": Color.INDIAN_RED},
	{"hold": "special_hold", "action": "special_action", "value": 1, "color": Color.PALE_GREEN},
	#{"hold": "", "action": "second_long_press_action", "value": 1, "color": Color.ORANGE}
]
const MAX_THRESHOLD: float = 1

func _ready() -> void:
	hp_bar.value = hp
	hp_bar.max_value = hp
	
func _process(delta: float) -> void:
	if hold_time>0:
		for i in THRESHOLDS.size():
			if hold_time <= THRESHOLDS[i]["value"] and hold_time > (THRESHOLDS[i-1]["value"]+0.1):
				if THRESHOLDS[i]["hold"] != "":
					call(THRESHOLDS[i]["hold"])
		
func evaluate_hold_time() -> void:
	for threshold in THRESHOLDS:
		if hold_time < threshold["value"]:
			call(threshold["action"])  # Dynamically call the associated function
			return  # Exit once the correct action is called
	overshoot_action()  # If no threshold is matched, call the overshoot action

func short_press_action() -> void:
	animation_player.play("attack")
	animation_player.queue("idle")
	
func first_long_hold() -> void:
	animation_player.play("hold_start")
	animation_player.queue("hold")
	
func special_hold() -> void:
	animation_player.play("hold")
	
func first_long_press_action() -> void:
	animation_player.play("fail")
	animation_player.queue("idle")

func special_action() -> void:
	animation_player.play("release")
	animation_player.queue("idle")
	var hitbox = hitbox_scene.instantiate()
	hitbox.user = self
	add_child(hitbox)
	

#func second_long_press_action() -> void:
	#animation_player.play("release")
	#animation_player.queue("idle")

func overshoot_action() -> void:
	special_action()

func move_to_target(object, start:Vector2, end:Vector2, speed:float):
	var tween = create_tween()
	tween.tween_property(object, "position", end, speed)
	await tween.finished
	#emit_signal(signal_name)
