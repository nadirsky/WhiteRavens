all: gatherData analize

gatherData:
	python gather.py

analize:
	./Analize.sh
