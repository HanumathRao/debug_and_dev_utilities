#!/usr/bin/make -f
COMPILER=mcs
EXECUTABLE_DIR=../../
EXECUTABLE=multithreaded_stock_quotes.exe
SOURCES_DIR=../../src/
SOURCES=*.cs

all: 
	$(COMPILER) $(SOURCES_DIR)$(SOURCES) -out:$(EXECUTABLE_DIR)$(EXECUTABLE)

clean:
	@echo Cleaning
	-rm -f $(EXECUTABLE_DIR)$(EXECUTABLE)
	@echo Cleaning done
	
.PHONY: all clean