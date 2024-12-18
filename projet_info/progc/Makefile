# Variables
CC = gcc
CFLAGS = -Wall -Wextra -g
LDFLAGS =
SOURCES = main.c avl.c
HEADERS = avl.h
TARGET = c-wire

# Règles
all: $(TARGET)

$(TARGET): $(SOURCES) $(HEADERS)
	$(CC) $(CFLAGS) $(SOURCES) -o $(TARGET)

clean:
	rm -f $(TARGET) *.o

.PHONY: all clean

