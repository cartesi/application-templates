CXX  := g++

.PHONY: clean 3rdparty

dapp: dapp.cpp
	make -C 3rdparty
	$(CXX) -pthread -std=c++11 -o $@ $^

clean:
	@rm -rf dapp
	make -C 3rdparty clean
