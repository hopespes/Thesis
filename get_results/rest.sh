#!/bin/sh
v_file="./../results/vanilla_alpha_zero_28/checkpoints/go/9x9/training_steps_4000.ckpt"
tk_file="./../results/top_k_alpha_zero_28/checkpoints/go/9x9/training_steps_7000.ckpt"
tbk_file="./../results/top_bot_k_alpha_zero_28/checkpoints/go/9x9/training_steps_5000.ckpt"
random_file="./../results/rand_alpha_zero_28/checkpoints/go/9x9/training_steps_6000.ckpt"

source ../rl_k_alpha_zero/venv/bin/activate
python3 eval_agent_go_mass_matches.py --num_processes=1 --num_games=10 --model1=4 --file1=$random_file --model2=2 --file2=$tbk_file
