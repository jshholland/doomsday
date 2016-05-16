module Main where

import Control.Monad      (replicateM_)
import Data.List          (intercalate)
import System.Clock
import System.Environment (getArgs)
import System.Exit        (exitFailure)
import System.IO          (hFlush, stdout)
import System.Random      (newStdGen, randoms)
import Text.Read          (readMaybe)

data WeekDay = Sunday | Monday | Tuesday | Wednesday | Thursday | Friday | Saturday
  deriving (Show, Read, Eq, Bounded, Ord)
type Year  = Int
type Month = Int
type Day   = Int

weekDayToInt :: WeekDay -> Int
weekDayToInt Sunday    = 0
weekDayToInt Monday    = 1
weekDayToInt Tuesday   = 2
weekDayToInt Wednesday = 3
weekDayToInt Thursday  = 4
weekDayToInt Friday    = 5
weekDayToInt Saturday  = 6

intToWeekDay :: Int -> WeekDay
intToWeekDay 0 = Sunday
intToWeekDay 1 = Monday
intToWeekDay 2 = Tuesday
intToWeekDay 3 = Wednesday
intToWeekDay 4 = Thursday
intToWeekDay 5 = Friday
intToWeekDay 6 = Saturday
intToWeekDay _ = undefined

anchorDay :: Year -> Int
anchorDay y = (5 * (c `mod` 4) + 2) `mod` 7
  where c = y `div` 100

yearToDoomsday :: Year -> Int
yearToDoomsday year = res `mod` 7
  where y      = year `mod` 100
        (a, b) = y `divMod` 12
        c      = b `div` 4
        res    = a + b + c + anchorDay year

doomsday :: Year -> Month -> Day
doomsday y 1 | isLeap y  = 4
             | otherwise = 3
doomsday y 2 | isLeap y  = 29
             | otherwise = 28
doomsday _ 3  = 0
doomsday _ 4  = 4
doomsday _ 5  = 9
doomsday _ 6  = 6
doomsday _ 7  = 11
doomsday _ 8  = 8
doomsday _ 9  = 5
doomsday _ 10 = 10
doomsday _ 11 = 7
doomsday _ 12 = 12

isLeap :: Year -> Bool
isLeap y = y `mod` 400 == 0 || y `mod` 100 /= 0 && y `mod` 4 == 0

dateToWeekDay :: Year -> Month -> Day -> WeekDay
dateToWeekDay y m d = intToWeekDay $ (d - doomsday y m + yearToDoomsday y) `mod` 7

askDays :: Int -> IO ()
askDays times = replicateM_ times askDay

askDay :: IO ()
askDay = do
  g <- newStdGen
  let [y', m', d'] = take 3 $ randoms g
      y            = 1700 + y' `mod` 600
      m            = 1 + m' `mod` 12
      d            = 1 + d' `mod` monthDays y m
      day          = dateToWeekDay y m d
  putStr $ intercalate "-" (map show [y, m, d]) ++ "? "
  hFlush stdout
  start <- getTime Monotonic
  ans <- readDay
  end <- getTime Monotonic
  let time = timeSpecAsNanoSecs $ diffTimeSpec start end
  if day == ans
     then putStrLn $ "Correct! You took " ++ show (time `div` 10^9) ++ " seconds."
     else putStrLn $ "Wrong! Correct answer was " ++ show day ++ "."

readDay :: IO WeekDay
readDay = do
  line <- getLine
  case readMaybe line of
    Just day -> return day
    Nothing  -> putStr "not a day, try again: " >> hFlush stdout >> readDay

monthDays :: Year -> Month -> Int
monthDays y 2 | isLeap y  = 29
              | otherwise = 28
monthDays _ m | m `elem` [1,3,5,7,8,10,12] = 31
              | otherwise                  = 30

usage :: IO ()
usage = putStrLn "usage: doomsday [number]" >> exitFailure

main :: IO ()
main = do
  args <- getArgs
  case args of
    [n] -> maybe usage askDays $ readMaybe n
    []  -> askDays 1
    _   -> usage
