GHCOPTS = -O2 -rtsopts

main: main.hs
	ghc ${GHCOPTS} $<

run: main
	./$<
