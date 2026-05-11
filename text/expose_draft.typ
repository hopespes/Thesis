#set text(font:"Open Sans", size:11pt, hyphenate: false)
//#set page(columns: 2, numbering:"1")

#place(
  top + center,
  scope: "parent",
  float: true,
  text(1.4em, weight: "bold")[
    BetaGo Mirco
  ],
)

A summarized plan of the planned bachelor thesis

#link("thesis.pdf")[thesis]

= Idea
- Go on 9x9 board
- Retrain AlphaGo Zero to have comparable training background
- Goal: A capable Go AI
  + A difficulty estimator -> Is it possible to reduce simulation cost by
    relying on a difficulty estimator that dynamically limits the maximal depth
    of the MCTS and this limit the necessary amount of calculations?
    - Maybe additional ways of limiting MCTS search space

  + (Or teach a model the rules/make it represent the learned rules -> How does
    the AI understand the rules it has learned? - A teaching AI that can
    symbolize concepts)


= Experiments
== Metrics
in regards to
- win rate
- number of simulations/calculations

+ Compare single net combining diff. est. and policy network and separate nets
  for diff. est and policy
+ Play against KataGo and compare in metrics
+ Use pretrained KataGo as evaluater on different game phases for accuracy

= Structure
+ Introduce the topic and the thesis
+ Explain history of Go AI, and important concepts (MCTS)
  - For the teacher model, also brielfy explain the rules of Go
+ (Explain the base model, e.g. AlphaGo, AlphaZero and) Explain the model
+ Experiments
+ Conclusion


= Environment
- Environment: Google Collab
- Libraries: PyTorch, OpenSpiel (as the basis for the game)


= Timeline
- 3 Weeks: Development and training of models 
- Month 2: Experiments
- Month 3: Evaluation, writing, finalization
