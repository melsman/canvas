.PHONY: all
all: viewer.py

viewer.py: viewer.fut ../lib/github.com/melsman/canvas/canvas.fut
	futhark-pyopencl --library viewer.fut

.PHONY: run
run: viewer.py
	PYOPENCL_CTX=0 ./viewer-gui.py

.PHONY: clean
clean:
	rm -rf *~ viewer.py viewer.pyc
