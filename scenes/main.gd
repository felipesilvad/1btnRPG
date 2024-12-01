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
var wait_2: bool = false

func _ready() -> void:
	# current_player_1 = turn_queue_1[0]
	# current_player_2 = turn_queue_2[0]
	set_current_player(1)
	set_current_player(2)
	create_threshold_bars(bar_1, current_player_1)
	create_threshold_bars(bar_2, current_player_2)
	setup_cursor(bar_1)
	setup_cursor(bar_2)
	
func set_current_player(side):
	if side ==1:
		if turn_queue_1.size() > 0:
			current_player_1 = turn_queue_1[current_player_1_index]
			current_player_1.active = true
			current_player_1.hold_time = 0
	else:
		if turn_queue_2.size() > 0:
			current_player_2 = turn_queue_2[current_player_2_index]
			current_player_2.active = true
			current_player_2.hold_time = 0

func start_next_turn(side):
	print('next turn')
	await get_tree().create_timer(0.2).timeout
	if side ==1:
		current_player_1_index = (current_player_1_index + 1) % turn_queue_1.size()
		set_current_player(side)
		create_threshold_bars(bar_1,current_player_1)
		wait_1 = false
	else:
		await get_tree().create_timer(0.2).timeout
		current_player_2_index = (current_player_2_index + 1) % turn_queue_2.size()
		set_current_player(side)
		create_threshold_bars(bar_2, current_player_2)
		wait_2 = false
		
func _process(delta: float) -> void:
	process_ai(delta)
	
	if wait_1 == false:
		if Input.is_action_pressed("ui_select"):
			current_player_1.is_holding = true
			current_player_1.hold_time += delta
			update_cursor(bar_1, current_player_1)
		else:
			if current_player_1.is_holding:
				current_player_1.evaluate_hold_time()
				end_turn(1)
			current_player_1.is_holding = false
			current_player_1.hold_time = 0.0
			update_cursor(bar_1, current_player_1)

func clear_bar(bar):
	bar.get_node('bar').queue_free()
		
func end_turn(side):
	if side == 1:
		clear_bar(bar_1)
		wait_1 = true
		current_player_1.hold_time = 0
		current_player_1.active = false
	else:
		clear_bar(bar_2)
		wait_2 = true
		current_player_2.hold_time = 0
		current_player_2.active = false
	
func process_ai(delta) -> void:
	if current_player_2.hold_time < (current_player_2.THRESHOLDS[1].value+0.05):
		current_player_2.is_holding = true
		current_player_2.hold_time += delta
		update_cursor(bar_2, current_player_2)
	else:
		if current_player_2.is_holding:
			current_player_2.evaluate_hold_time()
			end_turn(2)
		current_player_2.is_holding = false
		current_player_2.hold_time = 0.0
		
func update_cursor(bar, player) -> void:
	var position_x = (player.hold_time / player.MAX_THRESHOLD) * bar.size.x
	position_x = clamp(position_x, 0, bar.size.x)  # Prevent overflow
	bar.get_node('cursor').position = Vector2(position_x, 0)
	
func create_threshold_bars(bar, player) -> void:
	var previous_position: float = 0.0
	var bar_node = Control.new()
	bar_node.name = 'bar'
	bar.add_child(bar_node)
	for i in player.THRESHOLDS.size():
		var threshold = player.THRESHOLDS[i]
		var rect = ColorRect.new()
		# Calculate width based on the threshold value
		var threshold_width = ((threshold["value"] * bar.size.x) / player.MAX_THRESHOLD) - previous_position
		rect.position = Vector2(previous_position, 0)
		previous_position += threshold_width
		# Set size based on threshold width
		rect.size = Vector2(threshold_width, bar.size.y)  # Fill the parent's height
		# Set the color using Modulate
		rect.modulate = threshold["color"]
		rect.name = threshold["action"]
		bar_node.add_child(rect)

func setup_cursor(bar) -> void:
	var cursor = ColorRect.new()
	cursor.z_index = 11
	cursor.size = Vector2(1, bar.size.y)
	cursor.modulate = Color.WHITE
	cursor.position = Vector2(0, 0)
	cursor.name = 'cursor'
	bar.add_child(cursor)
