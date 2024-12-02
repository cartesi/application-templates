package rollups

import (
	"encoding/json"
)

type FinishRequest struct {
	Status string `json:"status"`
}

type FinishResponse struct {
	Type string          `json:"request_type"`
	Data json.RawMessage `json:"data"`
}

type InspectResponse struct {
	Payload string `json:"payload"`
}

type AdvanceResponse struct {
	Metadata Metadata `json:"metadata"`
	Payload  string   `json:"payload"`
}

type Metadata struct {
	ChainID        uint64 `json:"chain_id"`
	AppContract    string `json:"app_contract"`
	MsgSender      string `json:"msg_sender"`
	InputIndex     uint64 `json:"input_index"`
	BlockNumber    uint64 `json:"block_number"`
	BlockTimestamp uint64 `json:"block_timestamp"`
	PrevRandao     string `json:"prev_randao"`
}

type ReportRequest struct {
	Payload string `json:"payload"`
}

type NoticeRequest struct {
	Payload string `json:"payload"`
}

type VoucherRequest struct {
	Destination string `json:"destination"`
	Value       string `json:"value"`
	Payload     string `json:"payload"`
}

type ExceptionRequest struct {
	Payload string `json:"payload"`
}

type IndexResponse struct {
	Index uint64 `json:"index"`
}
