# Dynamic Adjustment of Monte Carlo Tree Search Simulations for A 9 x 9-Go-AI
A complete virtual environment is available with ./requirements.txt
- The code to evaluate the results is available under ./data/data.ipynb.
- The code to let the models play against each other is available under
  ./get_results.
  - Aside from rl_az, all models can be matched against each other with the
    following command from within the virtual environments avaiable in each
    model directory under ./results. Model 1 is always the black player:
    python3 eval_agent_go_mass_matches.py --model1=model1 --file1=./path/to/latest_1.ckpt --model2=model2 --file2=./path/to/latest_2.ckpt
  - To match rl_az as the black or white player, the following commands can be
    used respectively. The omitted model is rl_az:
    - python3 eval_agent_go_mass_matches_black.py --file1=./path/to/latest_1.ckpt --model2=model2 --file2=./path/to/latest_2.ckpt
    - python3 eval_agent_go_mass_matches_white.py --model1=model1 --file1=./path/to/latest_1.ckpt --file2=./path/to/latest_2.ckpt
- The trained models are available under ./results
