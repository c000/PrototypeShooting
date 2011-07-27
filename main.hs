import Game

main = do
  game <- initGame defaultConfig
  loopGame game
  quitGame game
