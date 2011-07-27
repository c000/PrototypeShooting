module Types where

import Data.Set

import Graphics.UI.SDL as SDL
import Graphics.UI.SDL.Mixer as MIX

import qualified Resources as R

class Renderable a where
  render :: Surface -> a -> IO Bool
  renderLocation :: Pixel -> Surface -> a -> IO Bool

class Movable a where
  move :: Game -> a -> a

data Game = GameStruct
  { gameWindow :: Surface
  , keyState :: Set SDLKey
  , player :: Splite
  , images :: R.Images
  , frames :: Int
  , bgm :: Music
  }

data Splite = Splite
  { surface :: Surface
  , surfaceOffset :: (Int, Int)
  , location :: (Double, Double)
  , radius :: Double
  , mover :: SpliteMover
  }

data SpliteMover = PassiveMover [(Double,Double)] (Double,Double)
                 | ActiveMover ( Game -> (Double,Double) )
