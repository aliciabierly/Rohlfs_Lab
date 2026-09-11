#!/bin/bash

OUT_DIR="/scratch/rohlfslab/abilery2/clair3"

wget -r -np -nH --cut-dirs=2 \
  -R "index.html*" \
  -P . \
  https://www.bio8.cs.hku.hk/clair3/clair3_models_pytorch/r941_prom_sup_g5014/

mv r941_prom_sup_g5014/ "${OUT_DIR}"
