set(GAME_SOURCES
  chess/chess.cc
  chess/chess.h
  chess/chess_board.cc
  chess/chess_board.h
  chess/chess_common.cc
  chess/chess_common.h
  chess/chess960_starting_positions.cc
  clobber/clobber.cc
  clobber/clobber.h
  efg_game/efg_game.cc
  efg_game/efg_game.h
  efg_game/efg_game_data.cc
  efg_game/efg_game_data.h
  go/go.cc
  go/go.h
  go/go_board.cc
  go/go_board.h
  go/sgf_game_loader.cc
  go/sgf_game_loader.h
  goofspiel/goofspiel.cc
  goofspiel/goofspiel.h
  kuhn_poker/kuhn_poker.cc
  kuhn_poker/kuhn_poker.h
  leduc_poker/leduc_poker.cc
  leduc_poker/leduc_poker.h
  leduc_poker/repeated_leduc_poker.cc
  leduc_poker/repeated_leduc_poker.h
  liars_dice/liars_dice.cc
  liars_dice/liars_dice.h
  matching_pennies_3p/matching_pennies_3p.cc
  matching_pennies_3p/matching_pennies_3p.h
  oh_hell/oh_hell.cc
  oh_hell/oh_hell.h
  pig/pig.cc
  pig/pig.h
  tic_tac_toe/tic_tac_toe.cc
  tic_tac_toe/tic_tac_toe.h
)

add_library (games OBJECT ${GAME_SOURCES})

target_include_directories (games PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories (games PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}../pybind11_abseil)
target_include_directories (games PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}../pybind11_json)
target_include_directories (games PUBLIC ${Python3_INCLUDE_DIRS})

add_executable(chess_test chess/chess_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(chess_test chess_test)

add_executable(clobber_test clobber/clobber_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(clobber_test clobber_test)

add_executable(go_test go/go_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(go_test go_test)

add_executable(sgf_game_loader_test go/sgf_game_loader_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(sgf_game_loader_test sgf_game_loader_test)

add_executable(efg_game_test efg_game/efg_game_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(efg_game_test efg_game_test)

add_executable(goofspiel_test goofspiel/goofspiel_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(goofspiel_test goofspiel_test)

add_executable(kuhn_poker_test kuhn_poker/kuhn_poker_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>
               $<TARGET_OBJECTS:algorithms>)
add_test(kuhn_poker_test kuhn_poker_test)

add_executable(liars_dice_test liars_dice/liars_dice_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>
               $<TARGET_OBJECTS:algorithms>)
add_test(liars_dice_test liars_dice_test)

add_executable(matching_pennies_3p_test matching_pennies_3p/matching_pennies_3p_test.cc
               ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>
               $<TARGET_OBJECTS:algorithms>)
add_test(matching_pennies_3p_test matching_pennies_3p_test)

add_executable(oh_hell_test oh_hell/oh_hell_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(oh_hell_test oh_hell_test)

add_executable(repeated_leduc_poker_test leduc_poker/repeated_leduc_poker_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(repeated_leduc_poker_test repeated_leduc_poker_test)

add_executable(pig_test pig/pig_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(pig_test pig_test)

add_executable(tic_tac_toe_test tic_tac_toe/tic_tac_toe_test.cc ${OPEN_SPIEL_OBJECTS}
               $<TARGET_OBJECTS:tests>)
add_test(tic_tac_toe_test tic_tac_toe_test)

