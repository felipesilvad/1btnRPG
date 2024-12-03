extends Player

var special_hitbox:PackedScene = preload("res://scenes/hitboxes/arrow.tscn")
var normal_hitbox:PackedScene = preload("res://scenes/hitboxes/slash.tscn")
var hp: int = 100
var move_speed: int = 100

const THRESHOLDS = [
	{"hold": "", "action": "short_press_action", "value": 0.1, "color": Color.LIGHT_GRAY},
	{"hold": "first_long_hold", "action": "first_long_press_action", "value": 0.75, "color": Color.INDIAN_RED},
	{"hold": "special_hold", "action": "special_action", "value": 1, "color": Color.PALE_GREEN},
	#{"hold": "", "action": "second_long_press_action", "value": 1, "color": Color.ORANGE}
]
const MAX_THRESHOLD: float = 1

func _ready() -> void:
	print(active)
	init_sm()
	hp_bar.value = hp
	hp_bar.max_value = hp
	
func _process(delta: float) -> void:
	#print(main_sm.get_active_state())
	if hold_time>0:
		for i in THRESHOLDS.size():
			if hold_time <= THRESHOLDS[i]["value"] and hold_time > (THRESHOLDS[i-1]["value"]+0.1):
				if THRESHOLDS[i]["hold"] != "":
					call(THRESHOLDS[i]["hold"])

func init_sm():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	var idle_state = LimboState.new().named('idle').call_on_enter(idle_start).call_on_update(idle_update)
	main_sm.add_child(idle_state)
	var walk_state = LimboState.new().named('walk').call_on_enter(walk_start).call_on_update(walk_update)
	main_sm.add_child(walk_state)
	var walk_back_state = LimboState.new().named('walk_back').call_on_enter(walk_back_start).call_on_update(walk_back_update)
	main_sm.add_child(walk_back_state)
	var attack_state = LimboState.new().named('attack').call_on_enter(attack_start).call_on_update(attack_update)
	main_sm.add_child(attack_state)
	var ready_state = LimboState.new().named('ready').call_on_enter(ready_start).call_on_update(ready_update)
	main_sm.add_child(ready_state)
	var hurt_state = LimboState.new().named('hurt').call_on_enter(hurt_start).call_on_update(hurt_update)
	main_sm.add_child(hurt_state)
	
	main_sm.initial_state = idle_state
	
	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(walk_state, attack_state, &"to_attack")
	main_sm.add_transition(main_sm.ANYSTATE, walk_back_state, &"to_walk_back")
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"to_idle")
	main_sm.add_transition(main_sm.ANYSTATE, hurt_state, &"to_hurt")
	main_sm.initialize(self)
	main_sm.set_active(true)

func idle_start():
	animation_player.play("idle")
func idle_update(_delta:float):
	pass

func walk_start():
	on_spot = false
func walk_update(delta:float):
	animation_player.play('move')
	if side == 1:
		position.x += move_speed * delta
	else:
		position.x -= move_speed * delta

func walk_back_start():
	pass
func walk_back_update(delta:float):
	reset_position(delta, move_speed)

func attack_start():
	attacking = false
	animation_player.play("attack")
	var hitbox = normal_hitbox.instantiate()
	hitbox.user = self
	add_child(hitbox)
	
func attack_update(_delta:float):
	pass

func ready_start():
	pass
func ready_update(_delta:float):
	pass
	
func hurt_start():
	animation_player.play('hurt')
	flash_white()
	await get_tree().create_timer(0.4).timeout
	main_sm.dispatch(&"to_walk_back")
	
func hurt_update(delta:float):
	pass

func evaluate_hold_time() -> void:
	for threshold in THRESHOLDS:
		if hold_time < threshold["value"]:
			call(threshold["action"])
			main.end_turn(side)
			return
	overshoot_action()

func short_press_action() -> void:
	attacking = true
	main_sm.dispatch(&"to_walk")
	
func first_long_hold() -> void:
	animation_player.play("hold_start")
	animation_player.queue("hold")
	
func special_hold() -> void:
	animation_player.play("hold")
	
func first_long_press_action() -> void:
	animation_player.play("fail")
	main.start_next_turn(side)	

func special_action() -> void:
	animation_player.play("release")
	var hitbox = special_hitbox.instantiate()
	hitbox.user = self
	add_child(hitbox)
	main.start_next_turn(side)
	
#func second_long_press_action() -> void:
	#animation_player.play("release")
	#animation_player.queue("idle")

func overshoot_action() -> void:
	special_action()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		main.start_next_turn(side)
		main_sm.dispatch(&"to_walk_back")
	if anim_name == "release" or anim_name == "fail":
		main_sm.dispatch(&"to_idle")
		animation_player.play('idle')
		#main.start_next_turn(side)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !attacking:
		return
	if side == 1:
		if body.side == 2:
			main_sm.dispatch(&"to_attack")
	else:
		if body.side == 1:
			main_sm.dispatch(&"to_attack")
