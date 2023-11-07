extends VBoxContainer
class_name CommentTextField

var parentComment = null
var username: String:
	set(value):
		if header != null:
			header.text = "Reply to " + value
		username = value
var trackId: String = ""

func init(
	initparentComment,
	initusername: String,
	inittrackId: String
):
	parentComment = initparentComment
	username = initusername
	if username == "":
		header.text = "Write a comment"
	trackId = inittrackId

@onready var header: Label = %Header
@onready var commentTextEdit: TextEdit = %CommentTextEdit
@onready var submitButton: Button = %SubmitButton

signal commentSubmitted()

func _ready():
	commentTextEdit.grab_focus()
	submitButton.pressed.connect(submitComment)
	if header != null:
		header.text = "Reply to " + username
	visibility_changed.connect(func(v): if v: commentTextEdit.grab_focus())

func submitComment():
	if commentTextEdit.text == "":
		return
	
	var data = {
		"track": trackId,
		"comment": commentTextEdit.text,
		"parentComment": parentComment
	}

	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 10
	request.request_completed.connect(onSubmitCommentCompleted)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/comments",
		[
			"Content-Type: application/json",
			"Session-Token: " + GlobalProperties.SESSION_TOKEN,
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)
	if httpError != OK:
		print("Error submitting comment: " + error_string(httpError))
	
	commentTextEdit.text = ""

func onSubmitCommentCompleted(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	commentSubmitted.emit()