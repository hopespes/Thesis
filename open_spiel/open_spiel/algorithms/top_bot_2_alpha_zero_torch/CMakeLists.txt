# To enable C++ Torch AlphaZero, you will need to set OPEN_SPIEL_BUILD_WITH_LIBTORCH.
if (OPEN_SPIEL_BUILD_WITH_LIBTORCH)
  if(NOT OPEN_SPIEL_BUILD_WITH_LIBNOP)
    message(FATAL_ERROR
      "alpha_zero_torch requires libnop (OPEN_SPIEL_BUILD_WITH_LIBNOP)")
  endif()

  add_library (top_bot_2_alpha_zero_torch OBJECT
    alpha_zero.h
    alpha_zero.cc
    device_manager.h
    model.h
    model.cc
    vpevaluator.h
    vpevaluator.cc
    vpnet.h
    vpnet.cc
    mcts.cc
    mcts.h
  )
  target_include_directories (top_bot_2_alpha_zero_torch PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

  # add_executable(top_bot_k_torch_model_test model_test.cc ${OPEN_SPIEL_OBJECTS}
  #               $<TARGET_OBJECTS:top_bot_k_alpha_zero_torch> $<TARGET_OBJECTS:tests>)
  # add_test(top_bot_k_torch_model_test top_bot_k_torch_model_test)
  #
  # add_executable(top_bot_k_torch_vpnet_test vpnet_test.cc ${OPEN_SPIEL_OBJECTS}
  #               $<TARGET_OBJECTS:top_bot_k_alpha_zero_torch> $<TARGET_OBJECTS:tests>)
  # add_test(top_bot_k_torch_vpnet_test top_bot_k_torch_vpnet_test)

  target_link_libraries (top_bot_2_alpha_zero_torch ${TORCH_LIBRARIES})
  # target_link_libraries (top_bot_k_torch_model_test ${TORCH_LIBRARIES})
  # target_link_libraries (top_bot_k_torch_vpnet_test ${TORCH_LIBRARIES})
endif ()
