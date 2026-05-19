add_executable(vanilla_alpha_zero_torch_training vanilla_alpha_zero_torch.cc
            ${OPEN_SPIEL_OBJECTS}
            $<TARGET_OBJECTS:vanilla_alpha_zero_torch>)
target_link_libraries (vanilla_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(compare compare.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:vanilla_alpha_zero_torch>)
target_link_libraries (compare ${TORCH_LIBRARIES})
add_executable(random_alpha_zero_torch_training random_alpha_zero_torch.cc
            ${OPEN_SPIEL_OBJECTS}
            $<TARGET_OBJECTS:random_alpha_zero_torch>)
target_link_libraries (random_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(rl_alpha_zero_torch_training rl_alpha_zero_torch.cc
            ${OPEN_SPIEL_OBJECTS}
            $<TARGET_OBJECTS:rl_alpha_zero_torch>)
target_link_libraries (rl_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(top_2_alpha_zero_torch_training top_2_alpha_zero_torch.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:top_2_alpha_zero_torch>)
target_link_libraries (top_2_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(top_5_alpha_zero_torch_training top_5_alpha_zero_torch.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:top_5_alpha_zero_torch>)
target_link_libraries (top_5_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(top_10_alpha_zero_torch_training top_10_alpha_zero_torch.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:top_10_alpha_zero_torch>)
target_link_libraries (top_10_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(top_bot_2_alpha_zero_torch_training top_bot_2_alpha_zero_torch.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:top_bot_2_alpha_zero_torch>)
target_link_libraries (top_bot_2_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(top_bot_5_alpha_zero_torch_training top_bot_5_alpha_zero_torch.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:top_bot_5_alpha_zero_torch>)
target_link_libraries (top_bot_5_alpha_zero_torch_training ${TORCH_LIBRARIES})
add_executable(top_bot_10_alpha_zero_torch_training top_bot_10_alpha_zero_torch.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:top_bot_10_alpha_zero_torch>)
target_link_libraries (top_bot_10_alpha_zero_torch_training ${TORCH_LIBRARIES})
