GO := go

.PHONY: clean

dapp: dapp.go
	$(GO) mod tidy
	$(GO) build 

clean:
	@rm -rf dapp
