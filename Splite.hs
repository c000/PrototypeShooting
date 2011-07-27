module Splite where

import Data.Set (toList)

import Graphics.UI.SDL as SDL

import Types

instance Renderable Splite where
  render window (Splite { surface = s
                        , surfaceOffset = (offx,offy)
                        , location = (x,y)
                        })
    =  blitSurface s Nothing window (Just $ Rect (floor x - offx) (floor y - offy) 0 0)

  renderLocation colorPixel window (Splite { location = (x,y) })
    = fillRect window (Just $ Rect (floor x - 1) (floor y - 1) 3 3) colorPixel

instance Movable Splite where
  move g0 (splite@(Splite { location = (x0,y0)
                          , mover = ActiveMover f
                          }))
    = splite { location = (x0 + mx, y0 + my) }
      where (mx, my) = f g0

playerMover = ActiveMover $ \(g0@(GameStruct {keyState = keys})) ->
    ( normalize
    . (foldr (\(a,b) (c,d) -> (a+c, b+d)) (0,0))
    . (map keyToMove)
    . toList
    ) keys
  where
    keyToMove :: SDLKey -> (Double, Double)
    keyToMove key = case key of
      SDLK_DOWN  -> ( 0, 1)
      SDLK_UP    -> ( 0,-1)
      SDLK_RIGHT -> ( 1, 0)
      SDLK_LEFT  -> (-1, 0)
      _          -> ( 0, 0)
    normalize (0,0) = (0,0)
    normalize (x,y) = let norm = sqrt (x*x + y*y) in (6 * x / norm, 6 * y / norm)
