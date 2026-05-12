add_executable(example example.cc ${OPEN_SPIEL_OBJECTS})
add_test(example_test example --game=tic_tac_toe --seed=0)


add_executable(policy_iteration_example policy_iteration_example.cc ${OPEN_SPIEL_OBJECTS})
add_test(policy_iteration_example_test policy_iteration_example)


if (OPEN_SPIEL_BUILD_WITH_LIBTORCH)
  add_executable(alpha_zero_torch_example alpha_zero_torch_example.cc
                ${OPEN_SPIEL_OBJECTS}
                $<TARGET_OBJECTS:alpha_zero_torch>)
  target_link_libraries (alpha_zero_torch_example ${TORCH_LIBRARIES})

  add_executable(alpha_zero_torch_game_example alpha_zero_torch_game_example.cc
                ${OPEN_SPIEL_OBJECTS}
                $<TARGET_OBJECTS:alpha_zero_torch>
                $<TARGET_OBJECTS:bots>)
  target_link_libraries (alpha_zero_torch_game_example ${TORCH_LIBRARIES})
endif ()

if (BUILD_SHARED_LIB)
  if (WIN32)
    add_executable(shared_library_example shared_library_example.cc ${OPEN_SPIEL_OBJECTS})
  else()
    add_executable(shared_library_example shared_library_example.cc)
  endif()
  target_link_libraries(shared_library_example open_spiel)
  add_test(shared_lib_test shared_lib_test)
endif()
