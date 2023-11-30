extends Node


var usercommand_list : Array[String]
var command_copy_idx = -1
@onready var input_field = $window/control/panel/lineEdit
@onready var scroll : ScrollContainer = $window/control/panel/panel/scrollContainer
@onready var msgbox : VBoxContainer = $window/control/panel/panel/scrollContainer/ConsoleMessageContainer
@onready var console : Window = $window
@onready var cvars : Node = $cvars
@onready var autocomplete_label : RichTextLabel = $window/control/AutoComplete
var expression = Expression.new()
var safe_mode := false:
	set(value):
		if value:
			add_console_message("-- Console is now in safe mode --", Color.DIM_GRAY)
		else:
			add_console_message("-- Console left safe mode --", Color.DIM_GRAY)
		safe_mode = value


var autocomplete_search_index : int = 0
var autocompletes : Array[String]


func _ready():
	console.hide()


func _on_line_edit_text_submitted(new_text: String) -> void:
	if usercommand_list.size() == 0:
		usercommand_list.push_front(new_text)
	if new_text != "" and usercommand_list[0] != new_text:
		usercommand_list.push_front(new_text)
	if usercommand_list.size() > 100:
		usercommand_list.pop_back()
	input_field.text = ""
	command_copy_idx = -1
	expression.parse(new_text)
	expression.execute([], cvars, false, safe_mode)
	if expression.get_error_text() != "":
		add_console_message(expression.get_error_text(), Color.YELLOW)


func add_console_message(message : String, color : Color = Color.WHITE) -> void:
	var new_label = Label.new()
	new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	new_label.text = message
	new_label.modulate = color
	msgbox.add_child(new_label)
	if msgbox.get_child_count() > 300:
		msgbox.get_child(0).queue_free()
	await get_tree().process_frame
	scroll.scroll_vertical = 50000


func add_rich_console_message(message : String) -> void:
	var new_label = RichTextLabel.new()
	new_label.fit_content = true
	new_label.bbcode_enabled = true
	new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	new_label.text = message
	msgbox.add_child(new_label)
	if msgbox.get_child_count() > 300:
		msgbox.get_child(0).queue_free()
	await get_tree().process_frame
	scroll.scroll_vertical = 50000


func _process(_delta: float) -> void:
	get_viewport().gui_disable_input = console.has_focus()
	display_autocompletion_results()

func warn_restricted(string : String) -> bool:
	if Console.safe_mode:
		Console.add_console_message("Cannot access '%s' in safe mode." % string, Color.LIGHT_CORAL)
		return true
	return false



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("devConsole"):
		console.hide()
		await get_tree().process_frame
		console.show()
		console.grab_focus()
		input_field.grab_focus()


func _on_window_window_input(event: InputEvent) -> void:
	if event.is_action_pressed("devConsole"):
		console.hide()
	if input_field.has_focus() and event.is_pressed():
		if event.as_text() == "Tab":
			if !autocompletes.is_empty():
				input_field.text = $window/control/panel/lineEdit/AutoCompletePreview.get_parsed_text()
				input_field.set_deferred("caret_column", input_field.text.length())
			return
		if event.as_text() == "Up":
			if usercommand_list.size() > 0 and autocompletes.is_empty():
				command_copy_idx += 1
				command_copy_idx = clamp(command_copy_idx, 0, usercommand_list.size() - 1)
				input_field.text = usercommand_list[command_copy_idx]
				await get_tree().process_frame
				input_field.caret_column = input_field.text.length()
				return
			autocomplete_search_index = clamp(autocomplete_search_index - 1, 0, autocompletes.size()-1)
		if event.as_text() == "Down":
			if usercommand_list.size() > 0 and autocompletes.is_empty():
				command_copy_idx -= 1
				command_copy_idx = clamp(command_copy_idx, 0, usercommand_list.size() - 1)
				input_field.text = usercommand_list[command_copy_idx]
				await get_tree().process_frame
				input_field.caret_column = input_field.text.length()
				return
			autocomplete_search_index = clamp(autocomplete_search_index + 1, 0, autocompletes.size()-1)


func clear() -> void:
	for i in msgbox.get_children():
		i.queue_free()
	add_console_message("Console cleared.", Color.DIM_GRAY)


func _on_window_focus_entered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func detect_autocomplete(new_text : String) -> void:
	autocompletes.clear()
	autocomplete_search_index = 0

	#We need to determine the autocomplete context aswell
	#Example, while in a function, navigating SceneTree nodes, etc.
	var fragments :PackedStringArray= new_text.split(".", true)
	var grabbed_object : Object
	var autocomplete_eval = Expression.new()
	#Before evaluating, we should get the return type of the function. If it's void, don't evaluate it.

	if fragments.size() > 0:
		for identifier in range(fragments.size()):
			var p_a :PackedStringArray= []
			for i in identifier:
				p_a.append(fragments[i])

			var parsing = ".".join(p_a)
			autocomplete_eval.parse(parsing)
			var result = await autocomplete_eval.execute([], cvars, true, true)
			if result is Object:
				grabbed_object = result
				continue

	if grabbed_object == null:
		var last_section = fragments[-1]
		last_section += "*?"
		for meth in cvars.get_method_list():
			if not meth["name"].begins_with("@") and meth["name"].matchn(last_section):
				var args = []
				for a in meth["args"]:
					args.append(a["name"])
				args = ",".join(args)
				if meth["name"] in ["get_node", "get_node_or_null", "get_node_and_resource"]:
					autocompletes.append("[color=lawn_green]%s[/color]"%(meth["name"]+"("+args+")"))
					continue
				autocompletes.append("[color=yellow]%s[/color]"%(meth["name"]+"("+args+")"))
		for prop in cvars.get_property_list():
			if not prop["name"].begins_with("@") and prop["name"].matchn(last_section):
				autocompletes.append(prop["name"])
	#Got an object, we can fill out autocompletes.
	else:
		var last_section = fragments[-1]
		last_section += "*?"
		for meth in grabbed_object.get_method_list():
			if not meth["name"].begins_with("@") and meth["name"].matchn(last_section):
				autocompletes.append("[color=yellow]%s[/color]"%(meth["name"]+"()"))
		for prop in grabbed_object.get_property_list():
			if not prop["name"].begins_with("@") and prop["name"].matchn(last_section):
				autocompletes.append(prop["name"])

func get_accessor() -> String:
	var regex = RegEx.new()
	regex.compile(".+?\\.")
	var b = regex.search_all(input_field.text)
	var txt = ""
	for m in b:
		txt += m.get_string()
	return txt

func display_autocompletion_results() -> void:
	var b = get_accessor()

	autocomplete_label.text = "[right]"
	$window/control/panel/lineEdit/AutoCompletePreview.text = ""
	if autocompletes.is_empty():
		return
	var display_min : int = clamp(autocomplete_search_index - 10, 0, autocompletes.size() - 1)
	var display_max : int = clamp(autocomplete_search_index + 10, 0, autocompletes.size())
	for idx in range(display_min, display_max):
		if autocompletes[autocomplete_search_index] == autocompletes[idx]:
			autocomplete_label.text += "[color=cyan][b]%s[/b][/color]\n" % globalGameManager.strip_bbcode(autocompletes[idx])
			continue
		autocomplete_label.text += autocompletes[idx] + "\n"
	$window/control/panel/lineEdit/AutoCompletePreview.text = b + autocompletes[autocomplete_search_index]

func null_catch(variable) -> bool:
	if variable == null:
		Console.add_console_message("Currently unavailable.", Color.LIGHT_CORAL)
	return variable == null
