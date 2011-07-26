import Data.Functor
import Data.Maybe (catMaybes)
import Data.Set
import System.IO (hFlush, stdout)

import Graphics.UI.SDL as SDL
import Graphics.UI.SDL.Mixer as MIX

import qualified Resources as R

data GameConfig = GameConfig
  { windowWidth  :: Int
  , windowHeight :: Int
  }

defaultConfig = GameConfig 400 600

data Game = GameStruct
  { gameWindow :: Surface
  , keyState :: Set SDLKey
  , player :: (Int, Int)
  , images :: R.Images
  , frames :: Int
  , bgm :: Music
  }

initGame (GameConfig w h) = do
  SDL.init [InitEverything]
  MIX.openAudio 44100 AudioS16Sys 2 1024
  music <- R.playBGM
  window <- setVideoMode w h 16 [HWSurface, DoubleBuf]
  img <- R.loadImages
  return $ GameStruct
    { gameWindow = window
    , keyState = empty
    , player = (200, 500)
    , images = img
    , frames = 0
    , bgm = music
    }

quitGame (GameStruct { gameWindow = w
                     , images = imgs
                     , bgm = music
                     }) = do
  freeSurface w
  R.freeImages imgs
  R.stopBGM music
  MIX.closeAudio
  quit

updateGame g0@(GameStruct {keyState = key}) = do
  g1 <- stepGame <$> getEvents g0
  render g1
  if isQuit then return ()
            else updateGame g1
    where
      isQuit = member SDLK_q key

getEvents g0@(GameStruct {keyState = sk}) = do
  e <- pollEvent
  case e of
    KeyDown (Keysym key _ _) -> getEvents $ g0 {keyState = insert key sk}
    KeyUp   (Keysym key _ _) -> getEvents $ g0 {keyState = delete key sk}
    NoEvent                  -> return g0
    _                        -> getEvents g0

stepGame g0@(GameStruct {keyState = keys}) = f g0
  where 
    keyList :: [SDLKey]
    keyList = toList keys
    f :: Game -> Game
    f = foldr1 (.) $
        defaultStep :
        ( catMaybes
        . (Prelude.map keyToAction)
        ) keyList
    defaultStep g@(GameStruct {frames = f}) = g {frames = f+1}

keyToAction :: SDLKey -> Maybe (Game -> Game)
keyToAction key = case key of
  SDLK_DOWN  -> Just $ movePlayer   0   6
  SDLK_UP    -> Just $ movePlayer   0 (-6)
  SDLK_RIGHT -> Just $ movePlayer   6   0
  SDLK_LEFT  -> Just $ movePlayer (-6)  0
  _          -> Nothing
  where
    movePlayer :: Int -> Int -> Game -> Game
    movePlayer x y g0@(GameStruct { player = (x0,y0)})
      = g0 { player = (x0+x, y0+y) }

render
  g0@(GameStruct { gameWindow = w
                 , player = (px, py)
                 , images = R.Images { R.backGround = bg
                                     , R.player = p
                                     }
                 , frames = f
                 })
  = do bgRendering
       red <- mapRGB windowPixelFormat maxBound 0 0
       True <- blitSurface p Nothing w (Just $ Rect (px-16) (py-16) 0 0)
       True <- fillRect w (Just $ Rect (px-1) (py-1) 3 3) red
    -- delay 1000
       SDL.flip w
       return g0
  where
    bgRendering = do
      let positionY = 2 * f `mod` 300
      True <- blitSurface bg Nothing w (Just $ Rect 0 (positionY-300) 0 0)
      True <- blitSurface bg Nothing w (Just $ Rect 0  positionY      0 0)
      True <- blitSurface bg Nothing w (Just $ Rect 0 (positionY+300) 0 0)
      return ()
    windowPixelFormat = surfaceGetPixelFormat w

main = do
  game <- initGame defaultConfig
  updateGame game
  quitGame game
