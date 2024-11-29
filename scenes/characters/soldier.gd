extends Player

var special_hitbox:PackedScene = preload("res://scenes/hitboxes/arrow.tscn")
var normal_hitbox:PackedScene = preload("res://scenes/hitboxes/slash.tscn")
var hp: int = 100
var move_speed: int = 100
var moving: bool = false
var moving_back: bool = false
var attacking: bool = false
var direction = Vector2(1,0).normalized()
var original_position: Vector2
@onready var main: Node2D = $"../../.."

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
	if moving:
		direction.x = 1
		var velocity = direction * move_speed * delta
		animation_player.play('move')
		var collision = move_and_collide(velocity)
		if collision:
			var groups = collision
			print(groups)
			moving = false
			attacking = true
			normal_action()
			await animation_player.animation_finished
			moving_back = true
			attacking = false
	elif moving_back:
		direction.x = -1
		reset_position(delta)
	else:
		if hold_time>0:
			for i in THRESHOLDS.size():
				if hold_time <= THRESHOLDS[i]["value"] and hold_time > (THRESHOLDS[i-1]["value"]+0.1):
					if THRESHOLDS[i]["hold"] != "":
						call(THRESHOLDS[i]["hold"])

func reset_position(delta):
	animation_player.play('move')
	get_node("Sprite2D").flip_h = true
	
	var velocity = direction * move_speed * delta
	move_and_collide(velocity)
	if position.distance_to(original_position) <= 1.0:  # Adjust threshold as needed
		position = original_position
		moving_back = false
		get_node("Sprite2D").flip_h = false
		animation_player.play('idle')
		main.start_next_turn(side)
		
func evaluate_hold_time() -> void:
	for threshold in THRESHOLDS:
		if hold_time < threshold["value"]:
			call(threshold["action"])  # Dynamically call the associated function
			return  # Exit once the correct action is called
	overshoot_action()  # If no threshold is matched, call the overshoot action

func short_press_action() -> void:
	moving = true
	
func first_long_hold() -> void:
	animation_player.play("hold_start")
	animation_player.queue("hold")
	
func special_hold() -> void:
	animation_player.play("hold")
	
func first_long_press_action() -> void:
	animation_player.play("fail")

func normal_action() -> void:
	animation_player.play("attack")
	var hitbox = normal_hitbox.instantiate()
	hitbox.user = self
	add_child(hitbox)
	
func special_action() -> void:
	animation_player.play("release")
	var hitbox = special_hitbox.instantiate()
	hitbox.user = self
	add_child(hitbox)
	
#func second_long_press_action() -> void:
	#animation_player.play("release")
	#animation_player.queue("idle")

func overshoot_action() -> void:
	special_action()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "release" or anim_name == "fail":
		animation_player.play("idle")
		main.start_next_turn(side)
