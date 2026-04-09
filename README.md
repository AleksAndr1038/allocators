
# Pool Allocator

This repository contains pool allocator implementation on haskell


## API Reference

#### createPool

```haskell
  createPool :: Int -> Int -> ST s (PoolAllocator s)
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `blockSize` | `Int` | Size of one memory block |
| `numBlocks` | `Int` | Number of blocks allocated |

#### allocate

```haskell
  allocate :: PoolAllocator s -> ST s (Maybe Int)
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `alloc`      | `PoolAllocator s` | parameter describing the pool allocator |

#### deallocate

```haskell
  deallocate :: PoolAllocator s -> Int -> ST s ()
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `dealloc`      | `PoolAllocator s` | parameter describing the pool allocator |
| `idx`      | `Int` | index of the block to be freed |



## Usage/Examples

```haskell
import PoolAllocator
import Control.Monad.ST
import Data.STRef

main :: IO ()
main = do
    let result = runST $ do
            allocator <- createPool 64 5

            block1 <- allocate allocator
            block2 <- allocate allocator
            block3 <- allocate allocator

            freeListState <- readSTRef (freeList allocator)

            case block2 of
                Just idx -> deallocate allocator idx
                Nothing -> return ()

            freeListAfter <- readSTRef (freeList allocator)

            block4 <- allocate allocator
            block5 <- allocate allocator
            block6 <- allocate allocator
            block7 <- allocate allocator

            return (block1, block2, block3, freeListState,
                    freeListAfter, block4, block5, block6, block7)

    -- теперь печатаем в IO
    putStrLn "1. Creating pool with 5 blocks of 64 bytes"

    let (block1, block2, block3, freeBefore,
         freeAfter, block4, block5, block6, block7) = result

    putStrLn "\n2. Allocating blocks:"
    putStrLn $ "   Block 1 allocated: " ++ show block1
    putStrLn $ "   Block 2 allocated: " ++ show block2
    putStrLn $ "   Block 3 allocated: " ++ show block3

    putStrLn $ "\n3. Remaining free blocks: " ++ show freeBefore

    putStrLn "\n4. Deallocating block 2"
    putStrLn "   Block 2 deallocated"

    putStrLn $ "\n5. Free blocks after deallocation: " ++ show freeAfter

    putStrLn "\n6. Allocating new block:"
    putStrLn $ "   Block 4 allocated: " ++ show block4

    putStrLn "\n7. Allocating remaining blocks:"
    putStrLn $ "   Block 5: " ++ show block5
    putStrLn $ "   Block 6: " ++ show block6

    putStrLn "\n8. Trying to allocate beyond limit:"
    putStrLn $ "   Block 7: " ++ show block7

-- Output:
-- 1. Creating pool with 5 blocks of 64 bytes

-- 2. Allocating blocks:
--    Block 1 allocated: Just 0
--    Block 2 allocated: Just 1
--    Block 3 allocated: Just 2

-- 3. Remaining free blocks: [3,4]

-- 4. Deallocating block 2
--    Block 1 deallocated

-- 5. Free blocks after deallocation: [1,3,4]

-- 6. Allocating new block:
--    Block 4 allocated: Just 1

-- 7. Allocating remaining blocks:
--    Block 5: Just 3
--    Block 6: Just 4

-- 8. Trying to allocate beyond limit:
--    Block 7: Nothing
```

