ssgenerator: 
	clang ssgenerator/*.m -framework Foundation -o bin/ssgenerator 

clean:
	rm -rf *.o ssgenerator
