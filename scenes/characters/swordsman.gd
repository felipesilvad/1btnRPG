extends Player

var special_hitbox:PackedScene = preload("res://scenes/hitboxes/arrow.tscn")
var normal_hitbox:PackedScene = preload("res://scenes/hitboxes/slash.tscn")
var hp: int = 100
var move_speed: int = 100

const THRESHOLDS = [
	{"hold": "", "action": "short_press_action", "value": 0.1, "color": Color.LIGHT_GRAY},
	#{"hold": "first_long_hold", "action": "first_long_press_action", "value": 0.5, "color": Color.LIGHT_YELLOW},
	{"hold": "special_hold", "action": "special_action", "value": 1, "color": Color.PALE_GREEN},
	#{"hold": "", "action": "second_long_press_action", "value": 1, "color": Color.ORANGE}
]
const MAX_THRESHOLD: float = 1

signal done

func _ready() -> void:
	hp_bar.value = hp
	hp_bar.max_value = hp
	
func _process(delta: float) -> void:
	if moving:
		if side == 1:
			position.x += move_speed * delta
		else:
			position.x -= move_speed * delta
	elif moving_back:
		reset_position(delta, move_speed)
	else:
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
	moving = true
	attacking = true

func special_hold() -> void:
	animation_player.play("hold")

func attack() -> void:
	moving = false
	normal_action()
	await animation_player.animation_finished
	moving_back = true
	attacking = false
	
func normal_action() -> void:
	animation_player.play("attack")
	var hitbox = normal_hitbox.instantiate()
	hitbox.user = self
	add_child(hitbox)
	main.start_next_turn(side)
	
func special_action() -> void:
	animation_player.play("release")
	var target_position = to_local(main.get_node('player2').get_node('spot2').global_position)
	move_to_target(self, position, Vector2(target_position.x-20, target_position.y), 0.7, "done")
	var hitbox = normal_hitbox.instantiate()
	hitbox.user = self
	hitbox.scale.x = 2
	hitbox.dmg = roundf(10 + (hold_time*8))
	hitbox.duration = 0.5
	add_child(hitbox)
	done.connect(move_back_on)
	main.start_next_turn(side)
	
func move_back_on():
	moving_back = true

#func second_long_press_action() -> void:
	#animation_player.play("release")
	#animation_player.queue("idle")

func overshoot_action() -> void:
	animation_player.play("fail")
	main.start_next_turn(side)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "release" or anim_name == "fail":
		animation_player.play("idle")
		#main.start_next_turn(side)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !attacking:
		return
	if side == 1:
		if body.side == 2:
			attack()
	else:
		if body.side == 1:
			attack()
