module Game where

import Data.Functor
import Data.Maybe (catMaybes)
import Data.Set
import System.IO (hFlush, stdout)

import Graphics.UI.SDL as SDL
import Graphics.UI.SDL.Mixer as MIX

import qualified Resources as R
import Types
import Splite

data GameConfig = GameConfig
  { windowWidth  :: Int
  , windowHeight :: Int
  }

defaultConfig = GameConfig 400 600

initGame (GameConfig w h) = do
  SDL.init [InitEverything]
  MIX.openAudio 44100 AudioS16Sys 2 1024
  window <- setVideoMode w h 16 [HWSurface, DoubleBuf]
  img <- R.loadImages
  return $ GameStruct
    { gameWindow = window
    , keyState = empty
    , player = Splite { surface = R.player img
                      , surfaceOffset = (16,16)
                      , location = (200, 500)
                      , radius = 32
                      , mover = playerMover
                      }
    , images = img
    , frames = 0
    , bgm = error "This branch have NO BGM."
    }

quitGame (GameStruct { gameWindow = w
                     , images = imgs
                     }) = do
  freeSurface w
  R.freeImages imgs
  MIX.closeAudio
  quit

loopGame g0@(GameStruct {keyState = key}) = do
  g1 <- stepGame <$> getEvents g0
  renderGame g1
  if isQuit then return ()
            else loopGame g1
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
        movePlayer :
        ( catMaybes
        . (Prelude.map keyToAction)
        ) keyList
    defaultStep g@(GameStruct {frames = f}) = g {frames = f+1}
    movePlayer  g@(GameStruct {player = p}) = g {player = move g0 p}

keyToAction :: SDLKey -> Maybe (Game -> Game)
keyToAction key = case key of
  _          -> Nothing

renderGame g0@(GameStruct { gameWindow = w
                 , player = p
                 , images = R.Images { R.backGround = bg
                                     }
                 , frames = f
                 })
  = do bgRendering
       red <- mapRGB windowPixelFormat maxBound 0 0
       True <- render w p
       True <- renderLocation red w p
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
