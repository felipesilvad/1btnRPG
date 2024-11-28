extends Player

var hitbox_scene:PackedScene = preload("res://scenes/hitbox.tscn")
var hp: int = 100
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
	print(main.chars_spots_2[0].name)
	#var global_pos = self.to_global(self.position)
	#var position_local_to_nodeB = main.chars_spots_2[0].to_local(global_pos)
	var target_position = self.to_local(main.chars_spots_2[0].global_position)
	move_to_target(self, self.position, target_position, 2, "moved_to_target")
	moved_to_target.connect(normal_action)
	
func first_long_hold() -> void:
	animation_player.play("hold_start")
	animation_player.queue("hold")
	
func special_hold() -> void:
	animation_player.play("hold")
	
func first_long_press_action() -> void:
	animation_player.play("fail")
	animation_player.queue("idle")

func normal_action() -> void:
	# Move back to the original position
	var original_position = position
	var movement = (original_position - global_position).normalized() * 100
	move_and_collide(movement)
	#else:
		## Move in the specified direction
		#var velocity = Vector2(direction * speed, 0)
		#var collision = move_and_collide(velocity * delta)
		#if collision:
			## Start the return process after a delay
			#yield(get_tree().create_timer(wait_time), "timeout")
			#_is_returning = true
	animation_player.play("attack")
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
