class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var hold_time: float = 0.0
var is_holding: bool = false

const THRESHOLDS = [
	{"hold": "", "action": "short_press_action", "value": 0.1, "color": Color.RED},
	{"hold": "first_long_hold", "action": "first_long_press_action", "value": 0.75, "color": Color.ORANGE},
	{"hold": "", "action": "critical_hit_action", "value": 0.85, "color": Color.YELLOW},
	{"hold": "", "action": "second_long_press_action", "value": 1, "color": Color.ORANGE}
]
const MAX_THRESHOLD: float = 1

func _process(delta: float) -> void:
	if hold_time>0:
		for i in THRESHOLDS.size():
			if hold_time <= THRESHOLDS[i]["value"] and hold_time >= THRESHOLDS[i-1]["value"]:
				printt(THRESHOLDS[i]["action"],THRESHOLDS[i]["value"],THRESHOLDS[i-1]["value"])
				if THRESHOLDS[i]["hold"] != "":
					call(THRESHOLDS[i]["hold"])
					return
		
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
	
func first_long_press_action() -> void:
	print("First Long Press detected!")

func critical_hit_action() -> void:
	print("Critical Hit!")

func second_long_press_action() -> void:
	print("Second Long Press detected!")

func overshoot_action() -> void:
	print("Overshoot!")

func move_to_target(object, start:Vector2, end:Vector2, speed:float):
	var tween = create_tween()
	tween.tween_property(object, "position", end, speed)
	await tween.finished
	#emit_signal(signal_name)
