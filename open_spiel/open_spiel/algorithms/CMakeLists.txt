add_library (algorithms OBJECT
  best_response.cc
  best_response.h
  cfr.cc
  cfr.h
  deterministic_policy.cc
  deterministic_policy.h
  evaluate_bots.cc
  evaluate_bots.h
  expected_returns.cc
  expected_returns.h
  get_all_states.cc
  get_all_states.h
  get_legal_actions_map.cc
  get_legal_actions_map.h
  history_tree.cc
  history_tree.h
  mcts.cc
  mcts.h
  minimax.cc
  minimax.h
  policy_iteration.cc
  policy_iteration.h
  tabular_exploitability.cc
  tabular_exploitability.h
)
target_include_directories (algorithms PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(best_response_test best_response_test.cc
        $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(best_response_test best_response_test)

# add_executable(cfr_test cfr_test.cc
#         $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
# add_test(cfr_test cfr_test)
#
add_executable(deterministic_policy_test deterministic_policy_test.cc
    $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(deterministic_policy_test deterministic_policy_test)

add_executable(evaluate_bots_test evaluate_bots_test.cc
    $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(evaluate_bots_test evaluate_bots_test)

add_executable(get_all_states_test get_all_states_test.cc
    $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(get_all_states_test get_all_states_test)

add_executable(get_legal_actions_map_test get_legal_actions_map_test.cc
    $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(get_legal_actions_map_test get_legal_actions_map_test)

add_executable(history_tree_test history_tree_test.cc
        $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(history_tree_test history_tree_test)

add_executable(minimax_test minimax_test.cc
    $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(minimax_test minimax_test)

add_executable(tabular_exploitability_test tabular_exploitability_test.cc
    $<TARGET_OBJECTS:algorithms> ${OPEN_SPIEL_OBJECTS})
add_test(tabular_exploitability_test tabular_exploitability_test)

add_subdirectory (alpha_zero_torch)
add_subdirectory (vanilla_alpha_zero_torch)
add_subdirectory (top_2_alpha_zero_torch)
add_subdirectory (top_5_alpha_zero_torch)
add_subdirectory (top_10_alpha_zero_torch)
add_subdirectory (top_bot_2_alpha_zero_torch)
add_subdirectory (top_bot_5_alpha_zero_torch)
add_subdirectory (top_bot_10_alpha_zero_torch)
add_subdirectory (rl_alpha_zero_torch)
