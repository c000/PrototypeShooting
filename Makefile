GHCOPTS = -O2 -rtsopts

main: main.hs *.hs
	ghc ${GHCOPTS} $<

run: main
	./$<
