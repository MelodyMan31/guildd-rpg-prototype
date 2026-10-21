class_name InteractionUI
extends CanvasLayer

signal dialogue_closed

# UI References
@onready var prompt_label: Label = $PromptLabel
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = ($DialoguePanel/VBoxContainer/SpeakerLabel)
@onready var body_label: Label = ($DialoguePanel/VBoxContainer/BodyLabel)
@onready var continue_label: Label = ($DialoguePanel/VBoxContainer/ContinueLabel)

# Dialogue State
var dialogue_open: bool = false
var pages: Array[String] = []
var page_index: int = 0

func _ready() -> void:
	add_to_group("interaction_ui")
	
	prompt_label.text = ""
	dialogue_panel.hide()
	
	_configure_layout()
	
# Position UI
func _configure_layout() -> void:
	#Interaction prompt near bottom center
	prompt_label.anchor_left = 0.5
	prompt_label.anchor_right = 0.5
	prompt_label.anchor_top = 1.0
	prompt_label.anchor_bottom = 1.0
	
	prompt_label.offset_left = -220.0
	prompt_label.offset_right = 220.0
	prompt_label.offset_top = -55.0
	prompt_label.offset_bottom = -20.0
	
	prompt_label.horizontal_alignment = (HORIZONTAL_ALIGNMENT_CENTER)
	
	# Dialogue window near bottom center
	dialogue_panel.anchor_left = 0.5
	dialogue_panel.anchor_right = 0.5
	dialogue_panel.anchor_top = 1.0
	dialogue_panel.anchor_bottom = 1.0
	
	dialogue_panel.offset_left = -330.0
	dialogue_panel.offset_right = 330.0
	dialogue_panel.offset_top = -225.0
	dialogue_panel.offset_bottom = -65.0
	
	body_label.autowrap_mode = (TextServer.AUTOWRAP_WORD_SMART)
	
# Interaction Prompt
func set_prompt(message: String) -> void:
	if dialogue_open:
		return
			
	prompt_label.text = message
	prompt_label.visible = not message.is_empty()
		
# Open Dialogue
func open_dialogue(
	speaker: String,
	new_pages: Array[String]
) -> void:
		
	if new_pages.is_empty():
		return
			
	pages = new_pages.duplicate()
	page_index = 0
	dialogue_open = true
		
	speaker_label.text = speaker
		
	prompt_label.hide()
	dialogue_panel.show()
	
	_show_page()
	
# Advance Dialogue
func advance_dialogue() -> void:
	if not dialogue_open:
		return
		
	page_index += 1
	
	if page_index >= pages.size():
		_close_dialogue()
	else:
		_show_page()

func _show_page() -> void:
	body_label.text = pages[page_index]
	
	continue_label.text = (
		"E / Cross: Continue (%d/%d)"
		% [page_index + 1, pages.size()]
	)
	
# Close dialogue
func _close_dialogue() -> void:
	dialogue_open = false
	dialogue_panel.hide()
	
	pages.clear()
	page_index = 0
	
	dialogue_closed.emit()
