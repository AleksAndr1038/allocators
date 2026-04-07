
# Pool Allocator

This repository contains pool and free-list allocators implementation on haskell


## API Reference

#### createPool

```http
  createPool :: Int -> Int -> ST s (PoolAllocator s)
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `blockSize` | `Int` | Size of one memory block |
| `numBlocks` | `Int` | Number of blocks allocated |

#### allocate

```http
  allocate :: PoolAllocator s -> ST s (Maybe Int)
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `alloc`      | `PoolAllocator s` | parameter describing the pool allocator |

#### deallocate

```http
  deallocate :: PoolAllocator s -> Int -> ST s ()
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `dealloc`      | `PoolAllocator s` | parameter describing the pool allocator |
| `idx`      | `Int` | index of the block to be freed |



## Usage/Examples

```javascript
import PoolAllocator
import Control.Monad.ST
import Data.STRef

main :: IO ()
main = do
    putStrLn "=== Pool Allocator Example ===\n"
    
    -- Run ST computation and get the result
    let result = runST $ do
            putStrLn "1. Creating pool with 5 blocks of 64 bytes"
            allocator <- createPool 64 5
            
            putStrLn "\n2. Allocating blocks:"
            block1 <- allocate allocator
            putStrLn $ "   Block 1 allocated: " ++ show block1
            
            block2 <- allocate allocator
            putStrLn $ "   Block 2 allocated: " ++ show block2
            
            block3 <- allocate allocator
            putStrLn $ "   Block 3 allocated: " ++ show block3
            
            freeListState <- readSTRef (freeList allocator)
            putStrLn $ "\n3. Remaining free blocks: " ++ show freeListState
            
            putStrLn "\n4. Deallocating block 2"
            case block2 of
                Just idx -> do
                    deallocate allocator idx
                    putStrLn $ "   Block " ++ show idx ++ " deallocated"
                Nothing -> return ()
            
            freeListAfter <- readSTRef (freeList allocator)
            putStrLn $ "\n5. Free blocks after deallocation: " ++ show freeListAfter
            
            putStrLn "\n6. Allocating new block:"
            block4 <- allocate allocator
            putStrLn $ "   Block 4 allocated: " ++ show block4
            
            putStrLn "\n7. Allocating remaining blocks:"
            block5 <- allocate allocator
            putStrLn $ "   Block 5: " ++ show block5
            
            block6 <- allocate allocator
            putStrLn $ "   Block 6: " ++ show block6
            
            putStrLn "\n8. Trying to allocate beyond limit:"
            block7 <- allocate allocator
            putStrLn $ "   Block 7: " ++ show block7
            
            return (block1, block2, block3, block4, block5, block6, block7)

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

