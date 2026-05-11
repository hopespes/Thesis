add_executable(top_2_alpha_zero_torch_training top_2_alpha_zero_torch.cc
			${OPEN_SPIEL_OBJECTS}
			$<TARGET_OBJECTS:top_2_alpha_zero_torch>)
target_link_libraries (top_2_alpha_zero_torch_training ${TORCH_LIBRARIES})
