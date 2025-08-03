class_name SaverLoader
extends Node
@onready var player: Player = %Player
@onready var world_root: WorldRoot = %WorldRoot

func save_game():
	var saved_game = SavedGame.new()
	saved_game.player_health = player.health
	saved_game.player_position = player.global_position
	# for fish in get_tree().get_nodes_in_group("fish"):
	# 	saved_game.fish_position.append(fish.global_position)
	# below code uses the game_events group and SavedData
	var saved_data:Array[SavedData] = []
	# following is new... and work done below is bit more important
	get_tree().call_group("game_events", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	# var file = FileAccess.open("user://savegame.data", FileAccess.WRITE)
	# file.store_var(player.global_position)
	# file.store_var(player.health)
	# file.close()
	
func load_game():
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	player.global_position = saved_game.player_position
	player.health = saved_game.player_health
	get_tree().call_group("game_events", "on_before_load_game")
	# remove the fish from the stages to avoid cluttering
	# for fish in get_tree().get_nodes_in_group("fish"):
		# cannot directly queue-free. Need to remove the node
	#	fish.get_parent().remove_child(fish)
	#	fish.queue_free()
	# for data in saved_game.fish_position:
	#	var fish_scn = preload("res://fish/fish.tscn")
	#	var fish = fish_scn.instantiate()
	#	world_root.add_child(fish)
	#	fish.global_position = data
	for item in saved_game.saved_data:
		var item_scene = load(item.scene_path) as PackedScene
		var obj = item_scene.instantiate()
		world_root.add_child(obj)
		if obj.has_method("on_load_game"):
			obj.on_load_game(item)
	# var file = FileAccess.open("user://savegame.data", FileAccess.READ)
	# player.global_position = file.get_var()
	# player.health = file.get_var()
	# file.close()
