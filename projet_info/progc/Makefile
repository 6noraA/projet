# Variables
CC = gcc
CFLAGS = -Wall -Wextra -g
LDFLAGS =
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)
HEADERS = $(wildcard *.h)
TARGET = c-wire

# Règles
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(TARGET) $(LDFLAGS)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

debug: CFLAGS += -DDEBUG
debug: clean all

clean:
    rm -f $(TARGET) $(OBJECTS)
    rm -f *.o


.PHONY: all clean debug
