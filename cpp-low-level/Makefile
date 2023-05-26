CXX  := g++

.PHONY: clean

dapp: dapp.cpp
	$(CXX) -pthread -std=c++17 -I /opt/riscv/kernel/work/linux-headers/include -o $@ $^

clean:
	@rm -rf dapp
