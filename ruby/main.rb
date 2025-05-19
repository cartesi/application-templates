require 'json'
require 'http'

def log(message)
  puts message
end

def handle_advance(data)
  log("Received advance request data #{data}")
  payload = data['payload']
  # TODO: add application logic here
  return "accept";
end

def handle_inspect(data)
  log("Received inspect request data #{data}");
  payload = data['payload']
  # TODO: add application logic here
  return "accept"
end

ROLLUP_SERVER = ENV.fetch('ROLLUP_HTTP_SERVER_URL', 'http://127.0.0.1:5004')
log("HTTP rollup_server url is #{ROLLUP_SERVER}")

finish = { status: "accept" }

while (true) do
  log("Sending finish")

  response = HTTP.post(ROLLUP_SERVER + '/finish', {
    headers: {
      'Content-Type': 'application/json'
    },
    json: { status: 'accept' }
  });

  log("Received finish status #{response.status}")

  if response.status == 202
    log("No pending rollup request, trying again")
  else
    rollup_req = response.parse
    metadata = rollup_req['data']['metadata']
    case rollup_req['request_type']
    when 'advance_state'
      finish[:status] = handle_advance(rollup_req['data'])
    when 'inspect_state'
      finish[:status] = handle_inspect(rollup_req['data'])
    end
  end
end
