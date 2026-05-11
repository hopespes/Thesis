#set text(font:"Open Sans", size:11pt, hyphenate: false)
#set page(numbering:"1")
#set par(justify: true)
#let fill = underline(text(red, weight: "bold")[FILL IN HERE])
#let check(txt) = underline(text(blue, weight: "bold")[CHECK THIS #txt])
#set heading(numbering: "1.1")

#place(
  top + center,
  scope: "parent",
  float: true,
  text(1.4em, weight: "bold")[
    Adjustment of Monte CarloTree Search #linebreak() Simulations for a
    9 #math.times 9-Go-AI
  ],
)

#outline()


#pagebreak()

= Introduction
In 1997, a computer program beat a reigning world chess champion for the first
time. This event marked a milestone in finding computational solutions to
complex cognitive tasks. Similar efforts have since been made for multiple
games, such as Shogi, #fill. Another important example of these efforts is the 
game Go. Significant efforts have been made to find a way to represent the 
game's rules and apply algorithms for the best game sequence. Until 2017,
Go players remained convinced that it took a human spark of creativity to
succesfully play Go.

= History
== Go
Go is a Chinese board game whose roots can be traced back to 4,000 years ago. It
is a zero-sum, two-player board game with perfect information that is usually 
played on a 19 #math.times 19 grid. The goal is to encase a larger number of line
intersections than the opponent. This is achieved by alternatingly placing coloured
but otherwise identical stones on the board so walls hold in other fields of the
board. 

This process is influenced by keeping alive one's own stones and capturing the
opponent's stones. The latter is done by filling in all the free intersections
around a connected group of the opponent's stone. The former is achieved by
having an unkillable group, meaning, that there always is at least one liberty
free however the opponent tries to lay down stones on the board. Importantly,
suicide is not allowed, i.e., a stone cannot be placed in a spot where the
connected group itself would die from having no available liberties. The
exception is when the surrounding group dies from this stone being placed. After
both players agree that the match is finished, the points are calculated.
Captured stones can be placed back in the enemy's territory or added to the
territory. Additionally, to balance out black's advantage in placing the first
stone, white receives komi, usually 6.5 or 7.5 additional points.

Because of its age and tradition in analogue play, Go has also drawn a lot of
interest in terms of creating machines capable of playing and beating human
players. This study of these machines is collectively called Computer Go

== Computer Go
Like other related fields, Computer Go started out with handmade, hard-coded
evaluation functions and estimations. Successes with this approach from
other fields are DeepBlue that was successful in 1996 in beating World-Chess
Champion Garry Kasparov. #check[] Noticeable examples are #fill

Other attempts used other strategies such as MCTS and #fill

With the wider usage of artificial neural networks, they also found adoption in
Computer Go. While first attempts that only used networks were not as efficient
as expected, later models utilized a hybrid approach using MCTS and neural
networks. This culminated in the model AlphaGo.

== AlphaGo and its legacy
AlphaGo is the first computer go model to successfully beat high-level
professionals in the game of Go. It makes use of artificial neural networks to
generate an estimation of best moves given a board position. This estimation is
subsequently used as the prior distribution for MCTS exploring the moves to find
the best.

= Background
== Monte Carlo Tree Search
Monte Carlo Tree Search (MCTS) is a heuristic decision making algorithm. It 
takes a state as input and finds the likely best subsequent state through 
exploration. There are four stages to MCTS.
+ Selection: From a parent node R, choose a child node according to a decision
  making equation. Repeat until choosing a leaf node C.
+ Expansion: If C is not a terminal node, e.g., in Go the game ends in a
  win/loss for the players, expand with probabilities for child states. Choose a
  child state.
+ Simulation: Execute one random rollout from C until leaf node. Execute random
  moves to reach a leaf node
+ Backpropagation: Update the probabilities in the path from C to R.
Through rigorous exploration of multiple hundred or thousand repetitions, the
better move sequences are expected to retain higher probabilities than worse
sequences.

The decision making algorithm used in MCTS is the Upper Confidence Bound applied
to Trees (UCT) which treats all moves the same until exploration
$
#[UCB1] (t)= hat(mu)_i+sqrt((2 ln(t)) / n_i)
$


== AlphaZero Algorithm
MCTS is accompanied within the AlphaGo Zero Algorithm with a neural network that
yields prior proabilities for for the expansion of a leaf node. This idea was
iterated on within the succession of the DeepMind models. For the first of the
DeepMind models, AlphaGo, a a neural model was trained on professional matches
which provides the prior probabilities. In self-play, i.e., the model plays
against another version of itself or itself, was used to refine the network. The
evaluation of the expanded node was generated using a smaller network that
played to a best-first selection until a terminal state. This was improved on in
AlphaZero as the multiple networks are replaced by a singular network providing
both prior probabilities as well as an evaluation through their respective head
in succession to the residual neural network. The decision making formula for
MCTS is slightly adapted for this algorithm to accomodate for the availability
of priors. Predictor Upper Confidence Bound applied for Trees.
$
U(s,a)=c_#[puct]P(s,a) sqrt(sum_b N(s,b))/(1+N(s,a))
$

The loss is calculated using the Mean Squared Error
$
l = (z-v)^2 - pi^T log p + c ||theta||^2.
$



//While AlphaGo stuck very closely to this idea, the underlying algorithm to 
//AlphaGo Zero and AlphaZero was a bit more loosely defined around this idea.
//Unlike AlphaGo, where there was a fast rollout-network in addition to the
//network, from which the priors of the MCTS were received, that was  capable of
//iterating to a terminal node from any leaf node. AlphaGo Zero made the
//innovation of receiving both the priors and an estimation of the likely winner
//from the Child node. The loss value is calculated with the difference between
//the probabilities and the difference in expected outcome. #check[probably more
//academic]




#pagebreak()

= Methodology

This thesis restricts the board size to 9 #math.times 9 to drastically lower
the complexity. While Go on a 19 #math.times 19 board is attributed a
state-space complexity of about $2 * 10^170$, 9 #math.times 9 boards lower the
complexity to around $1.039 * 10^38$. This is intended to enable more stable results
within the time frame of this thesis.

== Environment
The code implemented in this thesis relies heavily on the Google-Deepmind
library OpenSpiel. @LanctotEtAl2019OpenSpiel It provides a highly efficient
implementation of the general AlphaZero algorithm based on LibTorch. Training
was done on the university's high-performance clusters. #fill


== Metrics
The models were compared in terms of number of calculations and playing
strength. They were compared by playing against each other as well as the
OpenSpiel-built in elo estimator.

== Models
The base model is the OpenTorch-implementation of the AlphaZero algorithm. This
base model is modified using the following heuristics. #fill

=== Naïve Heuristic On Certainty
The first heuristic is a simple calculation of the average distance over a
number of the most likely moves according to the priors. 

=== Learning heuristic
Another heuristic will be implemented using a simple second network. This will
aim to evaluate the probabilities given by a the prior network and adjust the
amount of simulations accordingly. #check[]


= Experiments

== Training With Heuristics
In this first experiment, the models are trained with the heuristics enabled.

== Training Without Heuristics
In this experiment, the heuristics are only used for the self-play.

== Differences between models
In this experiment, the success between different presets of networks are
investigated.

// == Statical adjustment of MCTS Simulations
// In this experiment, the number of simulations will be adjusted to be lowered 

= Discussion 5 pages

= Conclusion 2 pages

#pagebreak()
#bibliography("sources.bib")
