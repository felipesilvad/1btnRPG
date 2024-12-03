extends Node2D

@onready var bar_1: Control = $Bar1
@onready var bar_2: Control = $Bar2

var value: float = 0.0
var current_player: Player
var current_player_index: int = 0
var turn_queue: Array
var wait: bool = false

func _ready() -> void:
	set_current_player()
	create_threshold_bars()
	setup_cursor(bar_1)
	setup_cursor(bar_2)

	
func set_current_player() -> void:
	if turn_queue.size() > 0:
		current_player = turn_queue[current_player_index]
		current_player.active = true
		current_player.get_node("Circle").visible = true
		current_player.hold_time = 0

func start_next_turn() -> void:
	print('next turn', current_player.side)
	await get_tree().create_timer(0.2).timeout
	current_player.active = false
	current_player_index = (current_player_index + 1) % turn_queue.size()
	set_current_player()
	create_threshold_bars()
	wait = false
	if current_player.side == 2:
		await get_tree().create_timer(0.5).timeout
		current_player.is_holding = true
		print(current_player.is_holding)
		

func _process(delta: float) -> void:
	process_ai(delta)
	
	if wait == false and current_player.side == 1:
		if Input.is_action_pressed("ui_select"):
			current_player.is_holding = true
			current_player.hold_time += delta
			update_cursor()
		else:
			if current_player.is_holding:
				current_player.evaluate_hold_time()
			current_player.is_holding = false
			current_player.hold_time = 0.0
			update_cursor()

func clear_bar(bar):
	#bar.get_node('bar').queue_free()
	for child in bar.get_children():
		if child.name != 'cursor':
			remove_child(child)
			child.queue_free()

func get_bar() -> Control:
	if current_player.side == 1:
		return bar_1
	else: return bar_2

func end_turn():
	var bar = get_bar()
	clear_bar(bar)
	wait = true
	current_player.hold_time = 0
	current_player.get_node("Circle").visible = false
	
func process_ai(delta) -> void:
	if current_player.side == 2:
		if current_player.hold_time < (current_player.THRESHOLDS[1].value+0.1):
			if current_player.is_holding:
				current_player.hold_time += delta
				update_cursor()
		else:
			if current_player.is_holding:
				current_player.evaluate_hold_time()
			current_player.is_holding = false
			current_player.hold_time = 0.0
		
func update_cursor() -> void:
	var bar = get_bar()
	var position_x = (current_player.hold_time / current_player.MAX_THRESHOLD) * bar.size.x
	position_x = clamp(position_x, 0, bar.size.x)  # Prevent overflow
	bar.get_node('cursor').position = Vector2(position_x, 0)
	
func create_threshold_bars() -> void:
	var bar = get_bar()
	var previous_position: float = 0.0
	var bar_node = Control.new()
	bar_node.name = 'bar'
	bar.add_child(bar_node)
	for i in current_player.THRESHOLDS.size():
		var threshold = current_player.THRESHOLDS[i]
		var rect = ColorRect.new()
		# Calculate width based on the threshold value
		var threshold_width = ((threshold["value"] * bar.size.x) / current_player.MAX_THRESHOLD) - previous_position
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
