extends Control
class_name CommentsContainer

@export
var trackId: String = '64fb19f35e616ef56517dfd0'

@onready var commentList: VBoxContainer = %CommentList
@onready var commentTextField: CommentTextField = %CommentTextField
@onready var closeButton: Button = %CloseButton

@onready var commentScene = preload("res://Menu/Comment.tscn")

signal closePressed()

func init(initTrackId: String):
	trackId = initTrackId
	loadComments(trackId)
	commentTextField.init(
		null,
		"",
		trackId,
	)
	closeButton.pressed.connect(func():
		hide()
		closePressed.emit()
	)
	commentTextField.commentSubmitted.connect(loadComments)
	visibility_changed.connect(onVisibilityChanged)

# func _ready():
# 	init(trackId)

func onVisibilityChanged():
	if get_parent() == null:
		return
	get_parent().mouse_filter = MOUSE_FILTER_STOP if visible else MOUSE_FILTER_IGNORE
	if visible:
		closeButton.grab_focus()

func loadComments(trackId: String = ""):
	if trackId == "":
		trackId = self.trackId
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 10
	request.request_completed.connect(onCommentsLoaded)

	var httpError = request.request(
		Backend.BACKEND_IP_ADRESS + "/api/comments/" + trackId,
		[
			"Content-Type: application/json",
		],
		HTTPClient.METHOD_GET,
	)
	if httpError != OK:
		print("Error loading comments: " + error_string(httpError))

func onCommentsLoaded(_result: int, _responseCode: int, _headers: PackedStringArray, _body: PackedByteArray):
	if _responseCode != 200:
		print("Error loading comments: ", _responseCode)
		return
	
	var comments = JSON.parse_string(_body.get_string_from_utf8())

	# for (let comment of data) {
	# 	// console.log(comment);
	# 	if (comment.parentComment == null) {
	# 		comment.indent = 0;
	# 	} else {
	# 		comment.indent = data.find((c: any) => c._id == comment.parentComment)?.indent + 1;
	# 	}
	# }
	for comment in comments:
		var parentCommentId = comment["parentComment"]
		if parentCommentId == null:
			comment["indent"] = 0
		else:
			var parent = getParentCommentIndex(parentCommentId, comments)
			comment["indent"] = comments[parent]["indent"] + 1

	var sortedComments = sortComments(comments)

	initializeCommentList(sortedComments)

func getParentCommentIndex(parentId, comments):
	for i in range(comments.size()):
		if comments[i]._id == parentId:
			return i
	return -1

func pushAllReplies(parent, comments, newArray):
	newArray.append(parent)
	for comment in comments:
		if comment.parentComment == parent._id:
			newArray = pushAllReplies(comment, comments, newArray)
	return newArray


func sortComments(comments):
	var newArray = []
	for comment in comments:
		if comment.parentComment == null:
			newArray = pushAllReplies(comment, comments, newArray)
	return newArray

func initializeCommentList(sortedComments):
	for child in commentList.get_children():
		if child is Comment:
			commentList.remove_child(child)
			child.queue_free()
	
	for comment in sortedComments:
		var commentInstance: Comment = commentScene.instantiate()
		commentList.add_child(commentInstance)
		commentInstance.init(
			comment.user.username,
			comment.user._id,
			comment.comment,
			comment.track,
			comment.indent,
			comment.rating,
			comment._id,
		)
		commentInstance.replySubmitted.connect(loadComments)
		commentInstance.commentDeleted.connect(loadComments)