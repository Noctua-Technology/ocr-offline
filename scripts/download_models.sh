#!/bin/bash

hf download PaddlePaddle/PaddleOCR-VL-1.5 \
    --local-dir ./models/PaddleOCR-VL-1.5

hf download PaddlePaddle/PP-DocLayoutV3 \
    --local-dir ./models/PP-DocLayoutV3
