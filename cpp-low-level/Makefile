# Copyright Cartesi and individual authors (see AUTHORS)
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

UNAME:=$(shell uname)

CC = gcc
STRIP = strip
CFLAGS +=-Wall -Wextra -pedantic -O2 `pkg-config --cflags libcmt`
LDLIBS += `pkg-config --libs libcmt`

all: dapp

dapp: export PKG_CONFIG_PATH ?= /usr/riscv64-linux-gnu/lib/pkgconfig
dapp: dapp.c
	$(CC) $(CFLAGS) -o dapp dapp.c $(LDLIBS)
	$(STRIP) dapp

clean:
	@rm -rf dapp
