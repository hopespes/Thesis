#set text(font:"Open Sans", size:11pt, hyphenate: false)
#set par(justify: true)
#set page(columns: 2)

#place(
  top + center,
  scope: "parent",
  float: true,
  text(1.4em, weight: "bold")[
    Dynamic Adjustment of Monte Carlo #linebreak() Tree Search Simulations for A
    9x9-Go-AI
  ],
)

This exposé will present a short overview of my bachelor thesis. The main topic
of the thesis will be the evaluation of dynamic adjustments to the number of
simulations executed by the Monte Carlo tree search (MCTS).

= Idea
The thesis restricts Go to a small board size of 9x9 as a bigger board requires
more capable hardware as well as more time to train. The core of the paper will
be to implement heuristic estimations for a model based on AlphaZero that
will increase and decrease the number of simulations executed by MCTS. This aims 
to lower the overall computational intensity. Previous work has largely been
done in making 

= Experiments
== Metrics
The model will be evaluated in terms of 
- final playing ability and 
- number of simulations and calculations executed during MCTS.

All models will receive the same amount of training time.

The thesis will introduce multiple heuristics. 
- Hard-coded functions 
- Learning models: e.g., Adaptive regressive model

= Overview 
+ Introduction
  - Motivation
  - Gap/Goal
  - Hypothesis
+ Background knowledge
  - Rules of Go
+ Concepts
  - ResNets
  - MCTS
+ Previous work
  - Pre-deep learning models
  - AlphaGo
  - AlphaZero
  - KataGo
+ Methodology
  - Reasoning 9 #math.times 9 vs. 19 #math.times 19
  - Reasoning AlphaZero vs. KataGo
  - Environment (Training server, implementation)
  - Training setup
  - Heuristics
  - Evaluation metrics
+ Experiments & Results
+ Discussion
+ Conclusion

= Environment
The development and training of the models will heavily rely on Google's
framework OpenSpiel as it provides a working implementation of AlphaZero. As the
model is implemented in C++, the implementation of the heuristics will also
happen done in C++. Preferably, training will be done on the university's
cluster because of the heavy computational requirements of the model.

= Timeline
#table(columns: (50%, 50%),
[Week 2],[Implementation of models],
[Week 6],[Training of models],
[Week 8],[Evaluation of models],
[Week 10],[Completion of writing],
[Afterwards],[Fixing up]
)
