extends PanelContainer


func set_data(name, desc, status):
	$VBoxContainer/Name.text = name
	$VBoxContainer/Desc.text = desc
	if status:
		$VBoxContainer/Status.text = "Выполнено"
	else:
		$VBoxContainer/Status.text = "Не выполнено"
