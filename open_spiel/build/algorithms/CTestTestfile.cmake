# CMake generated Testfile for 
# Source directory: /home/aplax/School/Thesis/open_spiel/open_spiel/algorithms
# Build directory: /home/aplax/School/Thesis/open_spiel/build/algorithms
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(best_response_test "best_response_test")
set_tests_properties(best_response_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;31;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
add_test(deterministic_policy_test "deterministic_policy_test")
set_tests_properties(deterministic_policy_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;39;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
add_test(evaluate_bots_test "evaluate_bots_test")
set_tests_properties(evaluate_bots_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;43;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
add_test(get_all_states_test "get_all_states_test")
set_tests_properties(get_all_states_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;47;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
add_test(get_legal_actions_map_test "get_legal_actions_map_test")
set_tests_properties(get_legal_actions_map_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;51;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
add_test(history_tree_test "history_tree_test")
set_tests_properties(history_tree_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;55;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
add_test(minimax_test "minimax_test")
set_tests_properties(minimax_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;59;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
add_test(tabular_exploitability_test "tabular_exploitability_test")
set_tests_properties(tabular_exploitability_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;63;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/algorithms/CMakeLists.txt;0;")
subdirs("alpha_zero_torch")
subdirs("simple")
