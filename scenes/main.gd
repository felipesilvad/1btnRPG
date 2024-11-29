extends Node2D

@onready var bar_1: Control = $Bar1
@onready var bar_2: Control = $Bar2

var value: float = 0.0
var current_player_1: Player
var current_player_2: Player
var current_player_1_index: int = 0
var current_player_2_index: int = 0
var chars_spots_1: Array
var chars_spots_2: Array
var turn_queue_1: Array
var turn_queue_2: Array
var wait_1: bool = false

func _ready() -> void:
	current_player_1 = turn_queue_1[0]
	current_player_2 = turn_queue_2[0]
	create_threshold_bars(bar_1)
	create_threshold_bars(bar_2)
	setup_cursor(bar_1)
	setup_cursor(bar_2)
	
func set_current_player(side):
	if side ==1:
		if turn_queue_1.size() > 0:
			current_player_1 = turn_queue_1[current_player_1_index]
			current_player_1.hold_time = 0
			print("Current ally:", current_player_1.name)
		
func start_next_turn(side):
	if side ==1:
		# Advance to the next ally in the queue
		current_player_1_index = (current_player_1_index + 1) % turn_queue_1.size()
		set_current_player(side)
		print(current_player_1.name)
		create_threshold_bars(bar_1)
		wait_1 = false
	else:
		current_player_2 = turn_queue_2[1]
		create_threshold_bars(bar_2)
		
func _process(delta: float) -> void:
	process_ai(delta)
	
	if wait_1 == false:
		if Input.is_action_pressed("ui_select"):
			current_player_1.is_holding = true
			current_player_1.hold_time += delta
			update_cursor(bar_1)
		else:
			if current_player_1.is_holding:
				current_player_1.evaluate_hold_time()
				end_turn(1)
			current_player_1.is_holding = false
			current_player_1.hold_time = 0.0
			update_cursor(bar_1)

func clear_bar(bar):
	bar.get_node('bar').queue_free()
		
func end_turn(side):
	if side == 1:
		clear_bar(bar_1)
		wait_1 = true
		current_player_1.hold_time = 0
	pass
	
func process_ai(delta) -> void:
	pass
	#if current_player_2.hold_time < (current_player_2.THRESHOLDS[1].value+0.05):
		#current_player_2.is_holding = true
		#current_player_2.hold_time += delta
		#update_cursor(bar_2)
	#else:
		#if current_player_2.is_holding:
			#current_player_2.evaluate_hold_time()
		#current_player_2.is_holding = false
		#current_player_2.hold_time = 0.0
		
func update_cursor(bar) -> void:
	var position_x = (current_player_1.hold_time / current_player_1.MAX_THRESHOLD) * bar.size.x
	position_x = clamp(position_x, 0, bar.size.x)  # Prevent overflow
	bar.get_node('cursor').position = Vector2(position_x, 0)
	
func create_threshold_bars(bar) -> void:
	var previous_position: float = 0.0
	var bar_node = Control.new()
	bar_node.name = 'bar'
	bar.add_child(bar_node)
	for i in current_player_1.THRESHOLDS.size():
		var threshold = current_player_1.THRESHOLDS[i]
		var rect = ColorRect.new()
		# Calculate width based on the threshold value
		var threshold_width = ((threshold["value"] * bar.size.x) / current_player_1.MAX_THRESHOLD) - previous_position
		rect.position = Vector2(previous_position, 0)
		previous_position += threshold_width
		# Set size based on threshold width
		rect.size = Vector2(threshold_width, bar.size.y)  # Fill the parent's height
		# Set the color using Modulate
		rect.modulate = threshold["color"]
		rect.name = threshold["action"]
		bar_node.add_child(rect)

func move_to_target(object, start:Vector2, end:Vector2, speed:float):
	var tween = create_tween()
	tween.tween_property(object, "position", end, speed)
	await tween.finished
	#emit_signal(signal_name)

func setup_cursor(bar) -> void:
	var cursor = ColorRect.new()
	cursor.z_index = 11
	cursor.size = Vector2(1, bar.size.y)
	cursor.modulate = Color.WHITE
	cursor.position = Vector2(0, 0)
	cursor.name = 'cursor'
	bar.add_child(cursor)
