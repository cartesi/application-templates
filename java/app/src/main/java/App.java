import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.codec.DecoderException;
import org.apache.commons.codec.binary.Hex;

public class App {
    static String rollups_server = System.getenv("ROLLUP_HTTP_SERVER_URL");
    static HttpClient client = java.net.http.HttpClient.newHttpClient();

    public static String handle_inspect(JsonNode data) {
        System.out.println("Inspecting state with data: " + data.toString());
        var hexData = data.get("payload").asText();

        return "accept";
    }

    public static String handle_advance(JsonNode data) {
        System.out.println("Advancing state with data: " + data.toString());
        var hexData = data.get("payload").asText();

        return "accept";
    }

    public static void main(String[] args) {
        ObjectMapper objectMapper = new ObjectMapper();
        String finishStatus = "accept";

        while (true) {
            try {
                JsonNode statusNode = objectMapper.createObjectNode().put("status", finishStatus);
                String requestBody = objectMapper.writeValueAsString(statusNode);

                var request = HttpRequest.newBuilder()
                        .uri(URI.create(rollups_server + "/finish"))
                        .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                        .build();

                var response = client.send(request, HttpResponse.BodyHandlers.ofString());
                System.out.println("Received finish status " + response.statusCode());

                if (response.statusCode() == 202) {
                    System.out.println("No pending rollup request, trying again");
                } else {
                    var rollupReq = response.body();
                    JsonNode rollupReqNode = objectMapper.readTree(rollupReq);
                    switch (rollupReqNode.get("request_type").asText()) {
                        case "inspect_state":
                            finishStatus = handle_inspect(rollupReqNode.get("data"));
                            break;
                        case "advance_state":
                            finishStatus = handle_advance(rollupReqNode.get("data"));
                            break;
                        default:
                            System.err.println("Unknown request type: " + rollupReqNode.get("request_type").asText());
                            finishStatus = "reject";
                            break;
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                System.err.println("An error occurred: " + e.getMessage());
            }
        }
    }
}