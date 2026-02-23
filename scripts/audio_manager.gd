extends Node

## Autoload singleton — plays sound effects from the assets/sounds/final/ folder.
## Usage: AudioManager.play("jump") or AudioManager.play("land") for random variant.

const SFX_PATH := "res://assets/sounds/final/"
const MAX_PLAYERS := 12

var players: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}

# Sound groups — keys map to arrays of AudioStream for random variant picking
var sound_map: Dictionary = {
	# Player
	"jump": ["jump.wav"],
	"land": ["land1.wav", "land4.wav", "land5.wav"],
	"strike_blip": ["strike_blip.wav"],
	"death_strike": ["death_strike1.wav", "death_strike2.wav", "death_strike3.wav"],
	"death_lava": ["death_lava1.wav", "death_lava2.wav", "death_lava3.wav", "death_lava4.wav",
		"death_lava5.wav", "death_lava6.wav", "death_lava7.wav", "death_lava8.wav"],

	# Arrow
	"arrow_fire": ["arrow_fire.wav"],
	"arrow_hit_wall": ["arrow_hit_wall.wav"],

	# Vine
	"vine_grab": ["vine_grab1.wav", "vine_grab2.wav"],
	"vine_break": ["vine_break2.wav", "vine_break3.wav", "vine_break4.wav"],
	"vine_creak": ["vine_creak_11.wav", "vine_creak_14.wav", "vine_creak_19.wav"],
	"vine_drop": ["vine_drop.wav"],

	# Enemies
	"death_bat": ["death_bat.wav"],
	"death_crawler": ["death_crawler.wav"],
	"death_ghost": ["death_ghost.wav"],
	"death_jumper": ["death_jumper.wav"],
	"bat_flutter": ["bat_flutter_a.wav", "bat_flutter_b.wav"],
	"crawler_move": ["crawler_move_fast.wav", "crawler_move_slow.wav"],
	"ghost_swoop": ["ghost_swoop1.wav", "ghost_swoop3.wav"],
	"jumper_bounce": ["jumper_bounce.wav"],

	# Environment
	"platform_rumble": ["platform_rumble.wav"],
	"switch_click": ["switch_click1.wav", "switch_click2.wav", "switch_click3.wav"],

	# Ghost alert — TODO: replace with proper "dun-dun-dunnnnn" stinger
	# "ghost_alert": ["ghost_alert.wav"],
}

func _ready() -> void:
	# Create audio player pool
	for i in MAX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		players.append(player)

	# Preload all sounds
	for key in sound_map:
		sounds[key] = []
		for filename in sound_map[key]:
			var path := SFX_PATH + filename
			var stream := load(path)
			if stream:
				sounds[key].append(stream)

func play(sound_name: String, volume_db: float = 0.0) -> void:
	if not sounds.has(sound_name) or sounds[sound_name].is_empty():
		return

	var stream_list: Array = sounds[sound_name]
	var stream: AudioStream = stream_list[randi() % stream_list.size()]

	# Find a free player
	for player in players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return

	# All busy — steal the oldest
	players[0].stream = stream
	players[0].volume_db = volume_db
	players[0].play()
