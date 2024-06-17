extends Node

var main
var is_hold := false
var player
var is_new := false

var is_dynamic_camera := true

var achievements


func show_tooltip(text: String):
	main.show_tooltip(text)

func hide_tooltip():
	main.hide_tooltip()

var achiv = {
	"Ночь 1": [false, "Твоя первая ночь..."],
	"Ночь 2": [false, "Что готовит новый день?"],
	"Ночь 3": [false, "Здесь вообще есть выход?"],
	"Ночь 4": [false, "Не унывай..."],
	"Ночь 5": [false, "Ты выжил 5 ночей! Но не с Фредди..."],
}

func _ready():
	var file_names = DirAccess.get_files_at("user://")
	for file_name in file_names:
		if file_name == "achiv.dlmp":
			print("ALREADY SAVED...")
			var file = FileAccess.open("user://achiv.dlmp", FileAccess.READ)
			achievements = file.get_var()

			file.close()
			return
	print("SAVE")
	var file = FileAccess.open("user://achiv.dlmp", FileAccess.WRITE)
	achievements = achiv
	file.store_var(achiv)
	file.close()

func save_data():
	var file = FileAccess.open("user://achiv.dlmp", FileAccess.WRITE)
	file.store_var(achievements)
	file.close()


