
.PHONY: demo
demo:
	make -C demo run

.PHONY: clean
clean:
	make -C demo clean
	rm -rf *~
