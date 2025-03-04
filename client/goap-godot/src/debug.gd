extends Control


@onready var goal_log: RichTextLabel = %GoalLog
@onready var message_log: RichTextLabel = %MessageLog


func _ready():
	DebugManager.debug_node = self
	message_log.text = ""
	goal_log.text = ""


func update_goal_log(text):
	goal_log.text = text


func update_message_log(text):
	goal_log.text = text


func add_log(text):
	message_log.text += "\n %s"+text
