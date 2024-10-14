#!/usr/bin/env php

<?php

require 'vendor/autoload.php';

use GuzzleHttp\Client;

$FINISH_PAYLOAD = ['status' => 'accept'];
$ROLLUP_SERVER = getenv("ROLLUP_HTTP_SERVER_URL") ?: "http://127.0.0.1:5004";

function handleAdvance($data) {
    $payload = hex2bin(substr($data['payload'], 2));
    error_log("Handling advance request for payload: $payload");

    return "accept";
}

function handleInspect($data) {
    $payload = hex2bin(substr($data['payload'], 2));
    error_log("Handling inspect request for payload: $payload");

    return "accept";
}

$client = new GuzzleHttp\Client(['base_uri' => $ROLLUP_SERVER]);

while (true) {
    error_log("Sending finish");

    $response = $client->request('POST', '/finish', [
        'json' => $FINISH_PAYLOAD
    ]);

    if ($response->getStatusCode() == 202) {
        error_log("No pending rollup request, trying again");
    } else {
        $rollup_req = json_decode($response->getBody(), true);
        $metadata = $rollup_req['data']['metadata'];

        switch ($rollup_req['request_type']) {
            case 'advance_state':
                $finish['status'] = handleAdvance($rollup_req['data']);
                break;
            case 'inspect_state':
                $finish['status'] = handleInspect($rollup_req['data']);
                break;
        }
    }
}

?>
