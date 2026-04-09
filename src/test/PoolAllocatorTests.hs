module Main where

import PoolAllocator
import Test.Hspec
import Control.Monad.ST

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
    describe "PoolAllocator" $ do
        it "allocates a single block" $ do
            let result = runST $ do 
                    alloc <- createPool 8 5
                    allocate alloc
            result `shouldBe` Just 0

        it "allocates multiple blocks in order" $ do
            let result = runST $ do
                    alloc <- createPool 8 3
                    a1 <- allocate alloc
                    a2 <- allocate alloc
                    a3 <- allocate alloc
                    return (a1, a2, a3)
            result `shouldBe` (Just 0, Just 1, Just 2)

        it "returns Nothing when pool is exhausted" $ do
            let result = runST $ do
                    alloc <- createPool 8 2
                    _ <- allocate alloc
                    _ <- allocate alloc
                    allocate alloc
            result `shouldBe` Nothing
        
        it "reuses deallocated block" $ do
            let result = runST $ do
                    alloc <- createPool 8 2

                    ma1 <- allocate alloc
                    a1 <- case ma1 of
                        Just x -> return x
                        Nothing -> error "Expected Just a"

                    _ <- allocate alloc
                    deallocate alloc a1
                    ma2 <- allocate alloc
                    return (ma2, a1)
            result `shouldBe` (Just 0, 0)

        it "handles deallocate and allocate sequence correctly" $ do
            let result = runST $ do
                    alloc <- createPool 8 3

                    ma1 <- allocate alloc
                    a1 <- case ma1 of
                        Just x -> return x
                        Nothing -> error "Expected Just a1"

                    ma2 <- allocate alloc
                    a2 <- case ma2 of
                        Just x -> return x
                        Nothing -> error "Expected Just a2"

                    deallocate alloc a1

                    ma3 <- allocate alloc
                    a3 <- case ma3 of
                        Just x -> return x
                        Nothing -> error "Expected Just a3"

                    return (a1, a2, a3)
            result `shouldBe` (0, 1, 0)

        it "free list grows after deallocation" $ do
            let result = runST $ do
                    alloc <- createPool 8 1

                    ma <- allocate alloc
                    a <- case ma of
                        Just x -> return x
                        Nothing -> error "Expected Just a"

                    deallocate alloc a
                    allocate alloc
            result `shouldBe` Just 0

        it "works with zero blocks" $ do
            let result = runST $ do
                    alloc <- createPool 8 0
                    allocate alloc
            result `shouldBe` Nothing
