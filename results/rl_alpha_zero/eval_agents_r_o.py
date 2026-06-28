# Copyright (c) 2023 Michael Hu.
# This code is part of the book "The Art of Reinforcement Learning: Fundamentals, Mathematics, and Implementation with Python.".
# This project is released under the MIT License.
# See the accompanying LICENSE file for details.


"""Evaluate different model's performance on Go by playing some matches."""
from absl import flags
import os
import sys
import re
from collections import OrderedDict
import logging
import multiprocessing as mp

import torch

FLAGS = flags.FLAGS
flags.DEFINE_integer('board_size', 9, 'Board size for Go.')
flags.DEFINE_float('komi', 7.5, 'Komi rule for Go.')
flags.DEFINE_integer(
    'num_stack',
    8,
    'Stack N previous states, the state is an image of N x 2 + 1 binary planes.',
)

flags.DEFINE_integer('num_res_blocks', 10, 'Number of residual blocks in the neural network.')
flags.DEFINE_integer('num_filters', 128, 'Number of filters for the conv2d layers in the neural network.')
flags.DEFINE_integer(
    'num_fc_units',
    128,
    'Number of hidden units in the linear layer of the neural network.',
)

flags.DEFINE_integer(
    'model1',
    0,
    'Load player 1.',
)
flags.DEFINE_string('file1', './checkpoints/go/9x9/training_steps_3000.ckpt', 'Checkpoint file for 1nd player')

flags.DEFINE_integer(
    'model2',
    0,
    'Load player 2.',
)
flags.DEFINE_string('file2', './checkpoints/go/9x9/training_steps_2000.ckpt', 'Checkpoint file for 2nd player')

flags.DEFINE_integer('num_simulations', 200, 'Number of iterations per MCTS search.')
flags.DEFINE_integer(
    'num_parallel',
    8,
    'Number of leaves to collect before using the neural network to evaluate the positions during MCTS search, 1 means no parallel search.',
)

flags.DEFINE_float('c_puct_base', 19652, 'Exploration constants balancing priors vs. search values.')
flags.DEFINE_float('c_puct_init', 1.25, 'Exploration constants balancing priors vs. search values.')

flags.DEFINE_integer('num_games', 20, '')

flags.DEFINE_integer('num_processes', 16, 'Run the games using multiple child processes')

flags.DEFINE_string(
    'save_match_dir',
    './9x9_matches',
    'Path to save statistics and game record in sgf format.',
)

flags.DEFINE_integer('seed', 1, 'Seed the runtime.')

flags.register_validator('num_games', lambda x: x >= 1)

# Initialize flags
FLAGS(sys.argv)

os.environ['BOARD_SIZE'] = str(FLAGS.board_size)

from alpha_zero.envs.go import GoEnv
from alpha_zero.core.network import AlphaZeroNet
from alpha_zero.core.pipeline import set_seed, disable_auto_grad, maybe_create_dir
from alpha_zero.utils.util import create_logger, get_time_stamp
from alpha_zero.utils.csv_writer import CsvWriter

def load_checkpoint_for_net(network, ckpt_file, device):
    if ckpt_file and os.path.isfile(ckpt_file):
        loaded_state = torch.load(ckpt_file, map_location=torch.device(device))
        print(loaded_state['network'])
        network.load_state_dict(loaded_state['network'])
    else:
        logging.warning(f'Invalid checkpoint file "{ckpt_file}"')


# def mcts_player_1_builder(network, ckpt_file, device):
#     network = network.to(device)
#     disable_auto_grad(network)
#     load_checkpoint_for_net(network, ckpt_file, device)
#     network.eval()
#
#     return vanilla_mcts(
#         network=network,
#         device=device,
#         num_simulations=FLAGS.num_simulations,
#         num_parallel=FLAGS.num_parallel,
#         root_noise=False,
#         deterministic=False,
#     )

# Models
# top_k:        1
# top_bot_k:    2
# rand:         3
def mcts_player_1_builder(network, ckpt_file, device, model):
    network = network.to(device)
    disable_auto_grad(network)
    load_checkpoint_for_net(network, ckpt_file, device)
    network.eval()

    player_1 = None
    if model == 1:
        from top_k_alpha_zero.core.pipeline import create_mcts_player as mcts_1
        player_1 = mcts_1
    elif model == 2:
        from top_bot_k_alpha_zero.core.pipeline import create_mcts_player as mcts_1
        player_1 = mcts_1
    elif model == 3:
        from rand_alpha_zero.core.pipeline import create_mcts_player as mcts_1
        player_1 = mcts_1
    else:
        from alpha_zero.core.pipeline import create_mcts_player as mcts_1
        player_1 = mcts_1

    return player_1

def mcts_player_2_builder(network, ckpt_file, device, model):
    network = network.to(device)
    disable_auto_grad(network)
    load_checkpoint_for_net(network, ckpt_file, device)
    network.eval()

    player_2 = None
    if model == 1:
        from top_k_alpha_zero.core.pipeline import create_mcts_player as mcts_2
        player_2 = mcts_2
    elif model == 2:
        from top_bot_k_alpha_zero.core.pipeline import create_mcts_player as mcts_2
        player_2 = mcts_2
    elif model == 3:
        from rand_alpha_zero.core.pipeline import create_mcts_player as mcts_2
        player_2 = mcts_2
    else:
        from alpha_zero.core.pipeline import create_mcts_player as mcts_2
        player_2 = mcts_2

    return player_2


def play_one_match(
    id,
    sgf_dir,
    env,
    black_network,
    white_network,
    black_ckpt,
    white_ckpt,
    device,
    c_puct_base,
    c_puct_init,
    model1,
    model2,
    file1,
    file2
):
    black_player = mcts_player_1_builder(black_network, file1, device, model1)
    white_player = mcts_player_2_builder(white_network, file2, device, model2)

    sim_1 = 0
    sim_2 = 0

    _ = env.reset()
    while True:
        if env.to_play == env.black_player:
            active_player = black_player
        else:
            active_player = white_player
        move, *_, sim = active_player(env, None, c_puct_base, c_puct_init)
        if env.to_play == env.black_player:
            sim_1 += sim
        else:
            sim_2 += sim
        _, _, done, _ = env.step(move)
        if done:
            break

    try:
        if os.path.exists(sgf_dir) and os.path.isdir(sgf_dir):
            sgf_content = env.to_sgf()
            sgf_file = os.path.join(sgf_dir, f'game_{id}.sgf')
            with open(sgf_file, 'w') as f:
                f.write(sgf_content)
                f.close()
    except Exception:
        pass

    return {
        'datetime': get_time_stamp(),
        'black': FLAGS.black_ckpt,
        'white': FLAGS.white_ckpt,
        'game': id,
        'game_result': env.get_result_string(),
        'game_length': env.steps,
        'player_1': sim_1,
        'player_2': sim_2
    }


def play_match_wrapper(args):
    return play_one_match(*args)


def main():
    set_seed(FLAGS.seed)

    maybe_create_dir(FLAGS.save_match_dir)
    writer = CsvWriter(os.path.join(FLAGS.save_match_dir, 'log.csv'), 1)

    logger = create_logger()
    runtime_device = 'cpu'
    if torch.cuda.is_available():
        runtime_device = 'cuda'
    elif torch.backends.mps.is_available():
        runtime_device = 'mps'

    def env_builder():
        return GoEnv(komi=FLAGS.komi, num_stack=FLAGS.num_stack)

    eval_env = env_builder()
    input_shape = eval_env.observation_space.shape
    num_actions = eval_env.action_space.n

    black_network = AlphaZeroNet(
        input_shape,
        num_actions,
        FLAGS.num_res_blocks,
        FLAGS.num_filters,
        FLAGS.num_fc_units,
    )
    white_network = AlphaZeroNet(
        input_shape,
        num_actions,
        FLAGS.num_res_blocks,
        FLAGS.num_filters,
        FLAGS.num_fc_units,
    )

    black_won = 0
    white_won = 0

    logger.info(f'Black: "{FLAGS.model1}"')
    logger.info(f'White: "{FLAGS.model2}"')

    process_args = [
        (
            i,
            FLAGS.save_match_dir,
            env_builder(),
            black_network,
            white_network,
            FLAGS.model1,
            FLAGS.model2,
            runtime_device,
            FLAGS.c_puct_base,
            FLAGS.c_puct_init,
            FLAGS.model1,
            FLAGS.model2,
            FLAGS.file1,
            FLAGS.file2
        )
        for i in range(FLAGS.num_games)
    ]

    logger.info(f'Starting to play {FLAGS.num_games} games, this will take some time...')
    with mp.Pool(processes=FLAGS.num_processes) as pool:
        result = pool.map_async(play_match_wrapper, process_args)
        stats = result.get()
        stats = sorted(stats, key=lambda x: x['game'])

    for item in stats:
        writer.write(OrderedDict((n, v) for n, v in item.items()))
        if re.match(r'B\+', item['game_result'], re.IGNORECASE):
            black_won += 1
        elif re.match(r'W\+', item['game_result'], re.IGNORECASE):
            white_won += 1

    writer.close()
    logger.info(f'Total games {FLAGS.num_games}, black won {black_won}, white won {white_won}')


if __name__ == '__main__':
    # Set multiprocessing start mode
    mp.set_start_method('spawn')
    main()
