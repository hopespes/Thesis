# CMake generated Testfile for 
# Source directory: /home/aplax/School/Thesis/open_spiel/open_spiel/examples
# Build directory: /home/aplax/School/Thesis/open_spiel/build/examples
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(example_test "example" "--game=tic_tac_toe" "--seed=0")
set_tests_properties(example_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/examples/CMakeLists.txt;2;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/examples/CMakeLists.txt;0;")
add_test(policy_iteration_example_test "policy_iteration_example")
set_tests_properties(policy_iteration_example_test PROPERTIES  _BACKTRACE_TRIPLES "/home/aplax/School/Thesis/open_spiel/open_spiel/examples/CMakeLists.txt;6;add_test;/home/aplax/School/Thesis/open_spiel/open_spiel/examples/CMakeLists.txt;0;")
