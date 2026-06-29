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
    'Load model for black player'
)
flags.DEFINE_string(
    'file1',
    './checkpoints/go/9x9/training_steps_5000.ckpt',
    'Load the checkpoint file for black player.',
)

flags.DEFINE_integer(
    'model2',
    0,
    'Load model for white player'
)
flags.DEFINE_string(
    'file2',
    './checkpoints/go/9x9/training_steps_6000.ckpt',
    'Load the checkpoint file for white player.',
)

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
from alpha_zero.core.pipeline import create_mcts_player, set_seed, disable_auto_grad, maybe_create_dir
from alpha_zero.utils.util import create_logger, get_time_stamp
from alpha_zero.utils.csv_writer import CsvWriter


def load_checkpoint_for_net(network, ckpt_file, device):
    if ckpt_file and os.path.isfile(ckpt_file):
        loaded_state = torch.load(ckpt_file, map_location=torch.device(device))
        network.load_state_dict(loaded_state['network'])
    else:
        logging.warning(f'Invalid checkpoint file "{ckpt_file}"')



def mcts_player_builder(network, ckpt_file, model, device):
    network = network.to(device)
    disable_auto_grad(network)
    load_checkpoint_for_net(network, ckpt_file, device)
    network.eval()

    if model == 1:
        from top_k.core.pipeline import create_mcts_player as top_k
        return top_k(
            network=network,
            device=device,
            num_simulations=FLAGS.num_simulations,
            top_k=5,
            num_parallel=FLAGS.num_parallel,
            root_noise=False,
            deterministic=False,
        )
    if model == 2:
        from top_bot_k.core.pipeline import create_mcts_player as top_k
        return top_k(
            network=network,
            device=device,
            num_simulations=FLAGS.num_simulations,
            top_k=5,
            num_parallel=FLAGS.num_parallel,
            root_noise=False,
            deterministic=False,
        )
    if model == 4:
        from rand.core.pipeline import create_mcts_player as rand
        return rand(
            network=network,
            device=device,
            num_simulations=FLAGS.num_simulations,
            top_k=5,
            num_parallel=FLAGS.num_parallel,
            root_noise=False,
            deterministic=False,
        )


    return create_mcts_player(
        network=network,
        device=device,
        num_simulations=FLAGS.num_simulations,
        top_k=5,
        num_parallel=FLAGS.num_parallel,
        root_noise=False,
        deterministic=False,
    )


def play_one_match(
    id,
    sgf_dir,
    env,
    black_network,
    white_network,
    black,
    black_ckpt,
    white,
    white_ckpt,
    device,
    c_puct_base,
    c_puct_init,
):
    black_player = mcts_player_builder(black_network, black_ckpt, black, device)
    white_player = mcts_player_builder(white_network, white_ckpt, white, device)

    black_sim = 0
    white_sim = 0

    _ = env.reset()
    while True:
        if env.to_play == env.black_player:
            active_player = black_player
        else:
            active_player = white_player
        move, *_, sim = active_player(env, None, c_puct_base, c_puct_init)
        if env.to_play == env.black_player:
            black_sim += sim
        else:
            white_sim += sim

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
        'black': FLAGS.model1,
        'black_ckpt': FLAGS.file1,
        'black_sim': black_sim,
        'white': FLAGS.model2,
        'white_ckpt': FLAGS.file2,
        'white_sim': white_sim,
        'game': id,
        'game_result': env.get_result_string(),
        'game_length': env.steps,
    }


def play_match_wrapper(args):
    return play_one_match(*args)


def main():
    set_seed(FLAGS.seed)

    save_match_dir = str(FLAGS.model1) + 'x' + str(FLAGS.model2) + '_matches'
    maybe_create_dir(save_match_dir)
    writer = CsvWriter(os.path.join(save_match_dir, 'log.csv'), 1)

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

    logger.info(f'Black: "{FLAGS.file1}"')
    logger.info(f'White: "{FLAGS.file2}"')

    process_args = [
        (
            i,
            save_match_dir,
            env_builder(),
            black_network,
            white_network,
            FLAGS.model1,
            FLAGS.file1,
            FLAGS.model2,
            FLAGS.file2,
            runtime_device,
            FLAGS.c_puct_base,
            FLAGS.c_puct_init,
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
