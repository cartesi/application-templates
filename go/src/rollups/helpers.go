package rollups

import (
	"encoding/json"
	"encoding/hex"
	"net/http"
	"bytes"
  "os"
)

var rollup_server = os.Getenv("ROLLUP_HTTP_SERVER_URL")

func SendPost(endpoint string, jsonData []byte) (*http.Response, error) {
  req, err := http.NewRequest(http.MethodPost, rollup_server + "/" + endpoint, bytes.NewBuffer(jsonData))
  if err != nil {
    return &http.Response{}, err
  }
  req.Header.Set("Content-Type", "application/json; charset=UTF-8")

  return http.DefaultClient.Do(req)
}

func SendFinish(finish *FinishRequest) (*http.Response, error) {
  body, err := json.Marshal(finish)
  if err != nil {
    return &http.Response{}, err
  }
  
  return SendPost("finish", body)
}

func SendReport(report *ReportRequest) (*http.Response, error) {
  body, err := json.Marshal(report)
  if err != nil {
    return &http.Response{}, err
  }
  
  return SendPost("report", body)
}

func SendNotice(notice *NoticeRequest) (*http.Response, error) {
  body, err := json.Marshal(notice)
  if err != nil {
    return &http.Response{}, err
  }
  
  return SendPost("notice", body)
}

func SendVoucher(voucher *VoucherRequest) (*http.Response, error) {
  body, err := json.Marshal(voucher)
  if err != nil {
    return &http.Response{}, err
  }
  
  return SendPost("voucher", body)
}

func SendException(exception *ExceptionRequest) (*http.Response, error) {
  body, err := json.Marshal(exception)
  if err != nil {
    return &http.Response{}, err
  }
  
  return SendPost("exception", body)
}

func Hex2Str(hx string) (string, error) {
  str, err := hex.DecodeString(hx[2:])
	if err != nil {
    return string(str), err
	}
  return string(str), nil
}

func Str2Hex(str string) string {
  hx := hex.EncodeToString([]byte(str))
  return "0x"+string(hx)
}
