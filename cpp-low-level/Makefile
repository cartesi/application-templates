CXX  := g++

.PHONY: clean

dapp: dapp.cpp
	$(CXX) -pthread -std=c++17 -I /include -o $@ $^

clean:
	@rm -rf dapp
