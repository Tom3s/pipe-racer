extends Node

func sendRequest(
	requesterNodeName: String,
	requestUrl: String,
	headers: Array,
	method: int,
	payload: String,
	timeout: float,
	onRequestSuccess: Callable,
) -> void:
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = timeout

	request.request_completed.connect(func(_result, response_code, _headers, _body):
		if response_code != 200:
			print("[" + requesterNodeName + "'s request] Error with response: " + _body.get_string_from_utf8())
			return
		onRequestSuccess.call(_body)
	)

	headers.append("Content-Type: application/json")

	var httpError = request.request(
		requestUrl,
		headers,
		method,
		payload
	)

	if httpError != OK:
		print("[" + requesterNodeName + "'s request] Error while sending request: " + error_string(httpError))
