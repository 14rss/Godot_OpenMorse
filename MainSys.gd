extends Control

@onready var morse_text_label: RichTextLabel = $Text/MorseTextLabel
@onready var clicker: Button = $Controls/Clicker
@onready var click_timer: Timer = $Controls/ClickTimer
@onready var off_timer: Timer = $Controls/OffTimer
@onready var letter_label: RichTextLabel = $Text/LetterLabel
@onready var feedback: AudioStreamPlayer = $Controls/Feedback
@onready var click_timer_progress: RadialProgress = $Controls/ClickTimerProgress # FROM "RADIAL PROGRESS" ON ASSETLIB
@onready var off_timer_progress: RadialProgress = $Controls/OffTimerProgress # FROM "RADIAL PROGRESS" ON ASSETLIB

# === LETTER/CHARACTER VARIABLES ===
var letter_history:String
var character_history:String

# === BOOL VARIABLES ===
var is_press_active:bool = false
var click_timer_finished:bool = false
var text_finished:bool = false

# === AUDIO VARIABLES ===
var playback: AudioStreamGeneratorPlayback
var is_beeping:bool = false
var phase:float = 0.0
var phase_increment:float = 0.0

# === AUDIO CONSTANTS ===
const FREQUENCY:float = 600.0
const VOLUME:float = 0.5
const SAMPLE_RATE:int = 11025

# Full morse code dictionary
var character_dict:Dictionary = {".-"="A","-..."="B",
"-.-."="C","-.."="D","."="E","..-."="F","--."="G",
"...."="H",".."="I",".---"="J","-.-"="K",".-.."="L",
"--"="M","-."="N","---"="O",".--."="P","--.-"="Q",".-."="R",
"..."="S","-"="T","..-"="U","...-"="V",".--"="W","-..-"="X",
"-.--"="Y","--.."="Z"

}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	letter_label.text = ""
	morse_text_label.text = ""
	phase_increment = 2.0 * PI * FREQUENCY/SAMPLE_RATE
	feedback.play()
	playback = feedback.get_stream_playback()


func _process(delta: float) -> void:
	if not is_beeping:
		return
	var samples_to_push:int = int(delta*SAMPLE_RATE)
	samples_to_push = clamp(samples_to_push,1,4096) # Caps samples
	for i in range(samples_to_push):
		if playback.can_push_buffer(1):
			var sample_value:float = sin(phase) * VOLUME
			playback.push_frame(Vector2(sample_value,sample_value))
			phase += phase_increment
			if phase >= 2.0 * PI:
				phase -= 2.0 * PI

# Handles beeping sound gen
func start_beep():
	is_beeping = true
	phase = 0.0
func stop_beep():
	is_beeping = false

# Clears the character history and morse label text for new character entry
func clear_character():
	character_history = ""
	morse_text_label.text = ""

# Sets click timer to true so clicker_button_up can calculate ./-
func _on_click_timer_timeout() -> void:
	click_timer_finished = true

# Handles click button up/down press (just a shortcut for space bar)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		_on_clicker_button_down()
	if event.is_action_released("click"):
		_on_clicker_button_up()

# When click button is pressed
func _on_clicker_button_down() -> void:
	start_beep()
	text_finished = false
	off_timer.stop()
	click_timer_finished = false
	is_press_active = true
	click_timer.start() # click_timer is used to calculate the length of the press to determine which character it should append
	click_timer_progress.animate(0.2,true) # Animates 0.2 second progress bar

# When click button is released
func _on_clicker_button_up() -> void:
	stop_beep()
	if click_timer_finished == true:
		character_history += "-" # Append character to history
		morse_text_label.text += "-" # Display on morse text label
	else:
		character_history += "." # Append character to history
		morse_text_label.text += "." # Display on morse text label
		print(character_history)
	click_timer.stop()
	off_timer.start() # off_timer is used to determine whether or not to start a new letter
	off_timer_progress.animate(0.3,true) # Animates 0.3 second progress bar

# Off timer calculates if should find characters in dictionary and print letter
func _on_off_timer_timeout() -> void:
	text_finished = true
	find_letter()

# Finds letter in dictionary based off character patterns
func find_letter():
	if character_history in character_dict:
		var current_letter:String = character_dict[character_history]
		letter_history += current_letter
		letter_label.text = str(letter_history)
	else:
		print("?") # Missing from dictionary/does not exist
	if off_timer.timeout:
		clear_character() # Clears characters after off timer finishes for new character

func clear_text(): # Clears all text
	letter_history = ""
	letter_label.text = str(letter_history)

func _on_clear_pressed() -> void: # Handles clear button input
	clear_text()
