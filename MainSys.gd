extends Control

@onready var morse_text_label: RichTextLabel = $Text/MorseTextLabel
@onready var clicker: Button = $Controls/Clicker
@onready var click_timer: Timer = $Controls/ClickTimer
@onready var off_timer: Timer = $Controls/OffTimer
@onready var letter_label: RichTextLabel = $Text/LetterLabel
@onready var feedback: AudioStreamPlayer = $Controls/Feedback
@onready var click_timer_progress: RadialProgress = $Controls/ClickTimerProgress
@onready var off_timer_progress: RadialProgress = $Controls/OffTimerProgress
@onready var feedback_2: AudioStreamPlayer = $Controls/Feedback2

# === LETTER/CHARACTER VARIABLES ===
var letter_history:String
var character_history:String

# === BOOL VARIABLES ===
var is_press_active:bool = false
var click_timer_finished:bool = false
var text_finished:bool = false

# === AUDIO VARIABLES ===
var playback: AudioStreamGeneratorPlayback
var playback2: AudioStreamGeneratorPlayback
var is_beeping:bool = false
var is_beeping2:bool = false
var phase:float = 0.0
var phase_increment:float = 0.0
var phase2:float = 0.0
var phase_increment2:float = 0.0

# === AUDIO CONSTANTS ===
const FREQUENCY:float = 600.0
const VOLUME:float = 0.5
const SAMPLE_RATE:int = 11025

const FREQUENCY2:float = 400.0

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
	phase_increment = 2.0 * PI * FREQUENCY/SAMPLE_RATE # Clicker beep phase
	phase_increment2 = 2.0 * PI * FREQUENCY2/SAMPLE_RATE # Add "K" button beep phase (+ space in text)
	feedback.play() # Beep always plays, but it holds the frames which it plays on
	playback = feedback.get_stream_playback()
	feedback_2.play()
	playback2 = feedback_2.get_stream_playback()
# Interestingly enough, the audio generation function isn't too hard on the processor at all
# In fact, it's only slightly harder on the processor than playing an mp3/wav/ogg file
# I thought it would be neat to have real time audio generation rather than a sound file
# Although, you may hear crackling in the audio, which is an inherent flaw here
# There are definitely ways to fix this, and I will implement them in the future
# But for now, I'm setting both audio gen nodes to different processor threads to smooth it out

func _process(delta: float) -> void:
	if is_beeping: # Processes first beep tone (for adding letters/characters)
		var samples_to_push:int = int(delta*SAMPLE_RATE)
		samples_to_push = clamp(samples_to_push,1,4096) # Caps samples
		for i in range(samples_to_push):
			if playback.can_push_buffer(1):
				var sample_value:float = sin(phase) * VOLUME
				playback.push_frame(Vector2(sample_value,sample_value))
				phase += phase_increment
				if phase >= 2.0 * PI:
					phase -= 2.0 * PI
	
	
	if is_beeping2: # Processes second beep tone (for adding spaces in text)
		var samples_to_push2: int = int(delta*SAMPLE_RATE)
		samples_to_push2 = clamp(samples_to_push2,1,4096)
		for i in range(samples_to_push2):
			if playback2.can_push_buffer(1):
				var sample_value2:float = sin(phase2) * VOLUME
				playback2.push_frame(Vector2(sample_value2,sample_value2))
				phase2 += phase_increment2
				if phase2 >= 2.0 * PI:
					phase2 -= 2.0 * PI
			

# Handles beeping sound gen
func start_beep():
	is_beeping = true
	phase = 0.0
func stop_beep():
	is_beeping = false
# Handles space beep sound gen
func start_beep2():
	is_beeping2 = true
	phase2 = 0.0
func stop_beep2():
	is_beeping2 = false

# Clears the character history and morse label text for new character entry
func clear_character():
	character_history = ""
	morse_text_label.text = ""

# Sets click timer to true so clicker_button_up can calculate ./-
func _on_click_timer_timeout() -> void:
	click_timer_finished = true

# Handles click button up/down press (just a shortcut for space bar)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"): # When space button is pressed down
		_on_clicker_button_down()
	if event.is_action_released("click"): # When space button is released
		_on_clicker_button_up()
	if event.is_action_pressed("space"): # "K" key adds a space. Will add a visual/audible marker in the future
		start_beep2()
		letter_history += " "
	if event.is_action_released("space"):
		stop_beep2()
	if event.is_action_pressed("clear"): # "C" key does the same thing as the clear button; clears text
		clear_text()

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
