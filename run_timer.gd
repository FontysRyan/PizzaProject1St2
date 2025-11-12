extends Node

var seconds_passed: int = 0
var minutes_passed: int = 0
var hours_passed: int = 0

var timer := Timer.new()
var running: bool = false

func _ready():
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)

func start():
	if not running:
		timer.start()
		running = true
		print("Timer started")

func pause():
	if running:
		timer.stop()
		running = false
		print("Timer paused")

func stop():
	timer.stop()
	running = false
	print("Timer stopped")

func reset():
	seconds_passed = 0
	minutes_passed = 0
	hours_passed = 0
	print("Timer reset")

func _on_timer_tick():
	seconds_passed += 1
	if seconds_passed % 60 == 0:
		minutes_passed += 1
	if minutes_passed % 60 == 0:
		hours_passed += 1

	# You can remove this print if you don’t want spam
	print("%02d:%02d:%02d" % [hours_passed, minutes_passed, seconds_passed % 60])
