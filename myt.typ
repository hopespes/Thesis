#set text(font:"Open Sans", size:11pt, hyphenate: false)
#set par(justify: true, leading: 1.5em)
#set heading(numbering: "1.1")
#show math.equation.where(block: false): box
#set math.equation(numbering: "(1)")

#show heading: it => {
  // v(0.5em)
  it 
  v(0.5em)
}

#let fill(txt) = underline(text(red, weight: "bold")[FILL #txt])
#let check(txt) = underline(text(blue, weight: "bold")[CHECK #txt])
#let cite = underline(text(green, weight: "bold")[CITE HERE])

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}

#import "@preview/simple-plot:0.3.0" : plot

#import "@preview/lets-go:0.1.0": go-board, go-board-9
#import "@preview/algorithmic:1.0.7"
#let AE=("left","bottom","right","top")

#let render-title-table(entries) = {
  align(
    center,
    grid(
      columns: 2,
      gutter: 1em,
      align: left,
      ..for (term, desc) in entries {
        ([*#term:*], desc)
      }
    )
  )
}

#let van = $"vanilla_az"$
#let topk = $"top_k_az"$
#let topbotk = $"top_bot_k_az"$
#let rl = $"rl_az"$
#let rand = $"rand_az"$

#let titlepage(
  title: [Dynamic Adjustment of Monte Carlo Tree Search Simulations for A 9 #math.times
9-Go-AI],
  titleGerman: "",
  degree: "Bachelor",
  program: "Cognitive Science",
  examiner1: "Tobias Thelen",
  examiner2: "Ulf Krumnack",
  supervisors: (),
  author: "Moritz Richter",
  startDate: datetime(year: 2026, month: 03, day: 10),
  submissionDate: datetime(year: 2026, month: 06, day: 29),
) = {
  // Quality checks
  assert(degree in ("Bachelor", "Master"), message: "The degree must be either 'Bachelor' or 'Master'")
  
  set page(
    margin: (left: 20mm, right: 20mm, top: 30mm, bottom: 30mm),
    numbering: none,
    number-align: center,
  )

  set text(
    // font: fonts.body, 
    size: 12pt, 
    lang: "en"
  )

  set par(leading: 0.5em)

  
  // --- Title Page ---
  v(5mm)
  align(center, text(
    // font: fonts.sans, 
    2em, 
    weight: 700, 
    "Osnabruck University")
  )

  v(5mm)
  align(center, text(
    // font: fonts.sans, 
    1.5em, 
    weight: 100, 
    "Institute for Cognitive Science")
  )
  
  v(15mm)
  align(center, text(
    // font: fonts.sans, 
    1.3em, 
    weight: 100, 
    degree + "’s Thesis in " + program)
  )
  v(8mm)
  

  align(center, text(
    // font: fonts.sans, 
    1.5em, 
    weight: 700, 
    title)
  )
  

  align(center, text(
    // font: fonts.sans, 
    2em, 
    weight: 500, 
    titleGerman)
  )

  let entries = ()
  entries.push(("Author", author))
  entries.push(([1st Examiner], examiner1))
  entries.push(([2nd Examiner], examiner2))
  // Only show supervisors if there are any
  if supervisors.len() > 0 {
    let supervisorField = "Supervisor" + if supervisors.len() > 1 [s]
    entries.push((supervisorField, supervisors.join(", ")))
  }
  entries.push(("Start Date", startDate.display("[day].[month].[year]")))
  entries.push(("Submission Date", submissionDate.display("[day].[month].[year]")))

  v(1cm)
  render-title-table(entries)
}

#titlepage()



#outline()
#pagebreak()
#let max_number=200
#set page(numbering:"1")

= Introduction
Creating a machine that is capable of playing games has
fascinated humanity @mechanical_turk for a long time and been an 
integral part of
computer science @turochamp since its inception. It is a benchmark for 
human intelligence and
explores the boundaries of what is possible using
automatic decision making. A major milestone was reached with the defeat of 
reigning world-chess
champion, Garry Kasparov, at the computations of the IBM 
chess computer DeepBlue
in 1997 @kasparov_v_deep_blue.
This event spurred on further improvement in chess machines that is still 
ongoing @stockfish_blog and research on a
multitude of other games. 
One such game was Go, which remained an
unbeaten challenge to
scientists for 19 more years @sedol_v_alphago. While many approaches 
were tested, it was not
until 2016 that, on equal footing, a
high-ranking professional player was beaten by Google-DeepMind's artificial
intelligence (AI), AlphaGo. AlphaGo used a vastly different approach from earlier
game computers and programs @alphago. It combined deep neural network (DNN) 
training with Monte Carlo Tree Search (MCTS), that is,
state exploration guided by learned policy networks. This work builds upon
AlphaZero, a generalisation of AlphaGo that achieves high performance without 
human knowledge.

MCTS based models like AlphaZero make use of a high number of simulations
during their search. However as such, MCTS requires large amounts of computational
power. This follows a trend in 
modern AI research and systems of growing requirements on
resources that are
necessary for training as well as for their subsequent 
deployment~@aireport. In the case of MCTS,  simulations are
executed even though the best action might already have the highest number of
visits.


This motivates the central claim of this thesis that the
efficiency of MCTS  augmented 
with predictors can
be increased by leveraging the predictor's values to dynamically adjust the
number of simulations without degrading performance in playing strength.
The development and implementation of such predictive heuristics are 
the goal of this 
thesis. In the end, these heuristics will be evaluated by playing  against each
other.

#linebreak()
During the course of this thesis, first, the theoretical background for this 
thesis is presented. 
Then the evolution of Go-AIs is described. Afterwards, the methods of this
project are explained.
Next, I show the results of the application of the developed heuristics. 
The heuristics show improved capability on the base model.#check([])
Lastly, the thesis is summarised.


= The Rules of Go
Go is a board game that originated in China with a history spanning more than 
4,000 years.  It is
played by two-players using black and white stones. While usually played on a 19
#math.times 19-grid, other board sizes like 9 #math.times 9 or 13 #math.times 13
are also common. 
The goal of the game is to enclose more territory, meaning, grid
intersections, than the opponent.

#figure(
  columns(2)[
    #figure(
      kind: "subfigure", supplement: "Figure",
      block(width: 5em, go-board(
        size: 3,
        stones: ("bb",),
        marks: ("ab","ba","bc","cb"),
        mark-radius: 7%,
        open-edges: AE,
        open-edges-added-length: 7%,
      )),
      caption: [Liberties of stones],
    ) <liberties>
    #colbreak()
    #figure(
      {
        block(width: 5em, go-board(
          size: 3,
          stones: ("ab", "bb", "ba", "bb", "bc"),
          marks: ("cb",),
          mark-radius: 7%,
          open-edges: AE,
          open-edges-added-length: 7%,
        ))
      },
      caption: [Capturing a Stone with #linebreak() the last liberty],
    ) <capturing>
  ],
)

The players place stones in turn; the player with the black stones begins. The
group of free places around a single stone are called liberties, see @liberties. 
Stones of the same colour that are placed on neighbouring fields are considered
a group and share the same liberties. A group may be arbitrarily large. A
group of the opponent can be captured by filling in all liberties of the
group, see @capturing, which removes them from the board. While generally any 
stone may be placed anywhere on the
board, it may not be placed in places where the stone or 
its group is captured because
of the stone having been placed. The exception is if the 
stone is the cause for
a successful capture of the opponent's stones. 
Importantly, a board position may
not be immediately repeated. This means,
after a stone has been captured, the capturing stone may not be recaptured
on the next move.
This is called Ko.
The game ends when both players pass consecutively, typically when all
meaningful moves have been played and the territories are settled.
Once the play is concluded, the territory is counted.
Unoccupied grid intersections within their territory each correspond to one
point for the respective
player. Captured stones each represent additional points for the player who
captured them. Captured stones that remain on the board while counting are worth
two points for the occupied field and the stone itself.

To compensate black's advantage in going first and avoid draw, additional
5.5-7.5 points are awarded to white. This is called komi.
Komi can be adjusted to even out the differences in capability
between inequally strong players. Lastly, komi can be combined with handicap
stones with which
black stones are placed on predetermined spots on the board before the start of
the game. In this case, the white players places the first stone.

Traditional ranks in Go are called kyu and dan, with an additional consideration
for professional players
Beginners' ranks start at 30 kyu reaching until 1 kyu. After 
reaching 1 kyu, players can advance from 1 dan to 9 dan. 
Professional players are ranked 
separately with their own dan-scale. Nowadays, players are also evaluated using
the Elo-system @elo. 


= Technical Background

== Supervised Learning
Supervised learning (SL) describes a machine learning (ML) paradigm in which an
agent is taught to recognise patterns from labeled data examples.

== Reinforcement Learning 
In contrast to SL, Reinforcement Learning (RL) is a collection of methods with 
which
an agent is trained to maximize a reward signal in interaction with its
environment @rl_intro.
Generally during training, an agent makes use of two concepts called
exploitation and exploration. On one side, exploitation
is choosing a path of action that is known to produce a good result. On the
other side, exploration is choosing a path of action that is not well-known and
thus, upon further examination, may produce a better result than already known
paths of action.

== Self-Play
Self-play is a training scheme within the field of RL @alphagozero. In self-play, an
algorithm competes against an earlier iteration of itself. In the scenario of
this paper, a training version plays a match of Go against a previous iteration
of itself. In this sense, 
the previous iteration is part of the environment and the reward signal is
the outcome of the match. Various selection strategies exist for the
iteration against which is played, for example, a random iteration is chosen to
play, or the
selection follows a "King-of-the-Hill"-approach, where the strongest iteration
remains as the benchmark and is to be beaten. This, more than the randomised
selection shows growth in performance of the agent.


== Neural Networks

=== Artificial Neural Networks
Currently, artificial neural networks (ANN) are one of the 
most used and researched
technologies. After their groundwork was laid in 1958 by Rosenblatt 
@perc_rosenblatt with the invention of the perceptron, new methods 
have been since
been developed for a large number of purposes, not the least of which is playing
games and improving strategies to superhuman levels.

One of the simplest structures of ANNs is the feedforward neural network
consisting of multiple layers of many stacked neurons. In this network, every
neuron receives an input from all neurons in the preceding layer plus a bias
individual per neuron. This is also known as dense layers.
ANNs receive an input of arbitrary format, defined per usecase.
During the forward pass, the
signal of 
this input is propagated through the network to the output layer @backprop. 
One layer is
made up of multiple neurons, each with its own weights per input, plus a bias
individual to each neuron. 
During RL, the ANN's output is evaluated for its reward signal in response 
to the environment. From this, an error signal is generated and passed backwards 
through the network. Each layer is updated dependent on the succeeding layer's,
error signal.


=== Convolutional Neural Networks
Most objects of the physical world depend on their multi-dimensional structure 
to be considered when
analysing them. Images, for example, rely on the spatial position of pixels in
relation to one another in order to correctly depict objects. Humans make use of
layered groups of neurons with distinct tasks to recognise groups of features
and form an understanding of objects from them.

Computationally, this structure is approximated using Convolutional Neural
Networks (CNN) that uses convolutional layers alongside or instead of dense
layers. Similarly to their biological counterparts, CNNs find
substructures that are common for multiple objects in early layers @cnn. Combining
these features in later layers enables recognition of more specific types of
objects.
In a convolutional layer, kernels, that is, tensors, operate on a
receptive field of inputs to generate outputs by sliding over the input making the
operation translationally invariant instead of operating on the whole input at
the same time. The weights in
these layers can be learned through training.

=== Residual Neural Networks
In the course of research and development of ANNs, they have grown exponentially
deeper. Beginning with single perceptrons, which were used in a single 
layer, modern networks use neurons with more than 100 layers and a 
large number of perceptrons per layer. Users of ANNs of this size noticed the 
problem of the vanishing gradient @resnet. 

To solve this problem, residual neural networks (ResNet) were introduced in Deep Learning
(DL) problems. ResNet's make use of  "skipping
connections" @resnet. In one of connection, a residual layer projects its output not only to the
succeeading layer but also to 
another
layer further down the stack of layers, skipping the layers inbetween. The
residual output is added to the output of the layer, to which it is is
projected.
This largely
fixes the vanishing gradient since the output of the layer is passed further
into the stack of layers. 

A negative point in this setup is that the intermediate layers may be found to
be superfluous and converge to $0$ during training but still demand the
necessary effort for their computation.

#linebreak()

Go, being a board game that is played in two-dimensions, 
is especially well-suited to being
analysed by CNNs. Much like recognising an object, situations such as
fights or life-and-death, in which, for example, two or more often 
neighbouring groups compete
for life, that cause a local effect can be
analysed in early layers and evaluated within the global context of the match in
later layers. For proper recognition and evaluation of local and global
situations, Go requires deep insight of the board. For more accurate
representations of the global position, the combination with ResNets therefore 
becomes vital to sustain trainability in growing networks.



== Monte Carlo Tree Search
MCTS is a versatile heuristic decision making algorithm. During the search, a 
tree is
built based on the original state represented by root node $R$. Every child node
$i$ of $R$ is a possible subsequent state from the state of $R$, 
in which an action $a_i$ was taken.
Through exploration of subsequent
state from $R$, MCTS finds a state that is most likely to maximise a
metric that can be changed per use-case. 
Every node $i$ of the tree keeps track of how many simulations made use of $i$,
$n_i$, and how many simulations are considered wins, $w_i$.
There are four stages to MCTS:
+ Selection: From $R$, choose a child node according to a selection
  method, often a variant of UCT @uct.
  Repeat until choosing a leaf node $C$.
+ Expansion: If $C$ is not a terminal state, which in Go is a state in which
  both players have passed and playing does not continue, 
  create new child nodes. Choose a new child state $S$ according to the
  selection method.
+ Evaluation #footnote[This step is also called simulation. For the sake of
  clarity within the scope of this thesis, "evaluation" will be used for this step
  of the process.]: Evaluate $S$. $S$ may be evaluated by choosing a child state
  using an rollout policy, e. g., randomly or a quick decision making unit
  @alphago,
  until a terminal state which has a definitive value. Another method is an
  evaluation function applied to $S$ @alphagozero.
+ Backpropagation: Update the visit and win counts in the path from $S$ to $R$
  under consideration of
  the result from the evaluation.
Through rigorous exploration of the tree by simulations, meaning, paths from root
to terminal nodes, the child states that most likely maximise the evaluation
method are expected to converge to higher values in the selection method.

In the context of AlphaZero, the states being represented by the nodes are
board positions in which moves are played as the selected actions that lead 
to child nodes or subsequent board positions.

MCTS returns a probability distribution in which better moves according to the
evaluation method have a higher evaluation in terms of the selection. This
probability distribution can be used as policy to choose moves in a play
scenario.

== Selection Methods
One selection method that is commonly used in MCTS's selection phase is the "Upper
Confidence Bound 1 applied to Trees" (UCT) @uct @alphago. It is used to find a balance
between exploitation of well-simulated moves and exploration of under-explored
moves in MCTS.
In the selection stage, node $i$ with the highest value according to the
expression
$ Q(s,a_i) + U(s,a_i) = w_i/n_i + c sqrt((ln N_i) / n_i) $
is selected, where 
- $Q(s,a) = w_i/n_i$ is a measure of how good $a_i$ is in state $s$, 
- $U(s,a) = sqrt((ln N_i) / n_i)$ is a measure of how well explored move $a_i$ is,
- $w_i$ is the number of wins that the successor states of $s$ accumulate if
  $a_i$
  is played,
- $n_i$ is the number of times that $a_i$ was chosen during the simulations,
- $N_i$ is the number of times that $s$ was part of the simulations,
- $c$ is an exploration parameter. The higher $c$, the more explorative the move
  selection is.
Since $N_i>=0$, $$ $sqrt((ln N_i)/n_i) approx infinity$ if $n_i=0$.
Consequently, every move is tried out at least
once.

#linebreak()

The Probabilistic Upper Confidence Bound applied to Trees (PUCT) is a variant of
UCT that incorporates prior estimations on the goodness of the actions of a state
@alphagozero.
These evaluations are typically provided
by predictors like a neural network or domain-specific heuristics.

It can use  different uncertainty formulas, for example:
$ U(s,a)=c_"puct" dot P(s,a) dot frac(sqrt(sum_b N(s,b)), 1+N(s,a)), $
where 
- $c_"puct"$ is a constant that guides the level of exploration and
- $P(s,a_i)$ is the evaluation of move $a_i$ in state $s$ according to the
  predictor.

Since $1+N(s,a)$, $frac(sqrt(sum_b N(s,b)), 1+N(s,a)) << infinity$. In effect,
unlike in UCT, not every move is forced to be simulated at least once, even
though unlikely in practice.

== AlphaGo

The AlphaGo-algorithm is a combined system of deep CNNs, MCTS, SL, and RL @alphago. 
SL policy network $p_sigma$ was trained from database of expert-level moves. 
The fast rollout policy $p_pi$ was designed to quickly execute reasonable 
moves until a final state in the evaluation step of MCTS.
RL policy network $p_rho$ on the other hand is trained to
optimize the outcome of self-play. The RL value network $v^p(s)$ predicts the
outcome based on the dataset created by $p_rho$'s selfplay.

*Supervised learning*. The first policy network $p_sigma (a|s)$ receives as input a
board representation $s$ and returns a move probability distribution over all
legal moves $a$. It is optimised to correctly predict the selection of move $a$,
given $s$, using stochastic gradient descent according to 
$Delta sigma prop frac(partial log p_(sigma)(a|s), partial sigma)$. 

*Reinforcement learning*. The second policy network $p_rho (a|s)$ is
architecturally the same. Its weights are initialised to the weights of the
$p_sigma$ and further trained
using policy gradient reinforcement learning. Self-play occurs between the 
current
and a random previous iteration of the network. The reward function is zero for
all non-terminal time steps and either $+1$ or $-1$ for winning and losing,
respectively. The gradient is calculated to 
$Delta rho prop frac(partial log p_(rho)(a_t|s_t), partial rho)z_t$.#linebreak()
The value network $v_theta (s)$ approaches the result from perfect
play $v^* (s)$ by approximating the result found through using the best policy of 
$p_rho$, $v^p(s)=EE[z_t|s_t=s,a_(t...T)~p]$.
Architecturally,
$v_theta$ is similar to the policy networks but is trained on state-outcome
pairs $(s, z)$ that are gathered during $p_rho$'s selfplay under stochastic 
gradient descent to minimize the mean-squared
error (MSE) between predicted value $v_theta (s)$ and the actual outcome $z$
$Delta theta prop frac(partial v_theta (s), partial theta)(z-v_(theta)(s))$. 

*Search* In MCTS, the selection follows PUCT. In the 
expansion, the prior
probabilties $P(s,a)$ for leaf node $s_L$ are provided by $p_rho$;
the evaluation $V(s_L)$ is generated by combining the value network's
output $v_theta (s_L)$ and the fast rollout's output $z_L$ through a 
weighting constant~$lambda$: 
$ V(s_L)=(1-lambda)v_theta (s_L) + lambda z_L. $
From the visit distribution after MCTS, the action with the most visits is
chosen.

== AlphaGo Zero
AlphaGo Zero represents a significant improvement over its predecessor,
achieving better performance through a more efficient architecture @alphagozero. By
eliminating the need for human expert data, it masters the game entirely through
self-play.

=== Structure of AlphaGo Zero
Unlike AlphaGo that uses separate policy and value networks, AlphaGo Zero makes
use of a single unified network, that consists of residual convolutional layers as 
well as
batch normalisation and rectifier nonlinearities. This network, $f_theta (s)$,
takes as input a board state
$s$ and outputs both move probabilities and state evaluation: $ (bold("p"), v) =
f_theta (s). $
The probability distribution $bold("p")$ is a vector over all allowed moves in
$s$, where $p_a = P(a | s)$. The scalar value $v in [-1, 1] approx EE[z,s]$ is the
expected outcome of the game, where $z$ is the outcome of the game. If $z$ is
equal to $1,$ the current player wins. If $z$ is equal to $-1,$ the opponent
wins.

The distribution $bold("p")$ and scalar $v$ guide the following MCTS in the
simulations. To avoid the agent narrowing in on suboptimal solutions,
Dirichlet-noise is added. A Dirichlet distribution $eta$, $eta tilde
op("Dir")(0.03),$ is added to $bold("p")$: $ P(s,a)=epsilon eta_a + (1-epsilon) 
p_a$, weighted by $epsilon$.

At each step during the simulation, the algorithm selects the action $a_t$ that
maximises PUCT using the predicted probability and
value from the network. 
After the allotted simulations, the MCTS-returned visit distribution is used to
create a new distribution
$ bold(pi)(a|s_0) = N(s,a)^(1/tau) / (sum_b N(s_0, b)^(1/tau)), $
where $tau$ is a temperature variable that controls exploration. Towards the end
of training $tau$ is made to approach $0$. This changes the resulting
distribution from a being flat to spiking.
From $ bold(pi)(a|s_0)$, the action is sampled.

// - $(z-v)^2$: Mean-squared loss,
// - $bold(pi) log (bold("p"))$: Cross-entropy loss,
// - $c||theta||^2$: L2-regularisation to avoid overfitting.

=== Training of AlphaGo Zero
AlphaGo Zero learns through an iterative self-play loop. The current best
version, whose weights are denoted by $theta$, plays against itself to generate 
a dataset of $(s_t, pi_t, z_t)$, that is, the state, the MCTS distribution, and
the final value of the game that the state comes from. 
The network is updated to minimise the composite loss function
$ l = (z-v)^2 - bold(pi) log bold("p") + c||theta||  ^2. $

Furthermore, the fact that Go is rotationally invariable is exploited by
rotating the board and thus generating more valid game positions.




== Kendall Rank Correlation Coefficient
The Kendall Rank Correlation Coefficient (KRCC) is a tool to
calculate the similarity of the same type of objects @rankcorrelation. 
In the context of this thesis, objects are AlphaGo Zero's predictor network's 
move probability distribution $bold("p")$ and 
MCTS' node frequency distribution
$bold(pi)$. Positions
within these distributions are always examined together.
In the implementation used in this thesis, all positions are iterated 
and compared to all following positions. A pair of positions is concordant if
both distributions agree either that $bold("p")_i <
bold("p")_j$ and $bold(pi)_i < bold(pi)_j$ or that $bold("p")_i > bold("p")_j$ 
and $bold(pi)_i > bold(pi)_j$.
This thesis uses specifially KRCC's variant $tau_b$ because equal values 
are possible in either
move probability distribution. 
In that case, 
a pair is tied if $bold("p")_i = bold("p")_j$ or $bold(pi)_i = bold(pi)_j$,
both may occur at the same time.
Otherwise, the pair is said to be discordant.
The formula is
$ tau_B = (n_c - n_d) / sqrt((n_0 - n_1) (n_0 - n_2)), $
where
- $n_0$ is the sum of all pairs, $n_0 = n(n-1) \/ 2$,
- $n_1$ is the sum of tied values in $bold("p")$, $n_1 = sum_i t_i (t_i - 1)/2$,
- $t_i$ is the number of tied values containing the $i$-th unique value,
- $n_2$ is the sum of tied values in $bold(pi)$, $n_1 = sum_j u_j (t_j - 1)/2$,
  and 
- $u_j$ is the number of tied values containing the $j$-th unique value.






== Elo
The Elo rating system is used to rank players of games such as Go and Chess. It
considers the likelihood of one player to win over their opponent @elo.
The central formulas are
$ E_A = 1 / (1+10^((R_B-R_A)/400)), $
which calculates the expected result of player $A$ with rating $R_A$ against
player $B$ with rating $R_B$, and
$ R'_A = R_A + K dot (S_A-E_A), $
which updates the ranking of player $A$. $S_A$ is the actual result and can be
$1$ for a win, $0.5$ for a draw, and $0$ for a loss.
Established players are attributed a lower factor $K$ to stabilize rankings, 
whereas newer
players have a higher factor $K$ to allow rankings to converge more 
quickly to their real ranking by increasing the gained points' coefficient.

Elo points can give an intuition on how likely one player is to win over the
other. For example, player $A$ with $400$ points more
than his opponent $B$ in the Elo system
should win $10$ games out of $11$ because from $R_B-R_A=-400$ follows 
$1/(1+10^(-1))=91%$.






= Historical Evolution
== Before Deep Learning

=== Before MCTS

Early Go programs were usually rule-based and used pattern
recognition combined with heuristic evaluation functions and search
to find hard-coded patterns and choose actions based on the results.

One such program is "The Many Faces of Go" that was using a large compilation of
rules and an influence function @manyfaces_patterns.  It was competing
successfully in Computer Go
championships in 1998-2002. It was widely considered one of the best 
Go programs of
the time @computer_go. At the time, it reported online strength
estimates at 8 kyu, corresponding to an Elo value of circa 1200.
It has since been continuously improved and made to
embrace new technologies until the introduction of deep learning @manyfaces_mcts.

A freely consultable open-source program of the time that 
also works based on
rules and pattern-recognition is GnuGo @gnugo. Shortly, within the pipeline,
GnuGo first analyses the board
for its state, examines groups, their life-and-death, and their relation to one
another. Next, it generates the moves, and lastly evaluates the moves for its
effect on influence and territory. The move with the highest score is
played.




=== After MCTS

Earlier Go programs were found to perform well in specific parts of the game like
life-and-death problems or local tactical analysis @computer_go. However they
were unable to play a complete game well or even better than amateur players.
Programs of this level of sophistication could not achieve the same level of
success
for Go as for chess, because the computational search for Go is drastically
different. While it is not the only factor, the state-space is much larger on a
large board,
$3^(19 times 19) approx 10^170$ of which $1.2%$ are legal. However, Go on a 
9 #math.times 9-board has a
similar branching factor to chess and has proved equally as difficult as Go on
a large board. This is due to static position evaluation requiring a large 
amount
of local auxiliary computations. Additionally, in order to find legal moves, the
recent history of the game has to be contained within the state information 
to account
for special rules such as Ko that forbid repetition.

As the typical game is also much longer than in chess, MCTS is a tool better 
suited to explorations because it is capable of a more
dynamical approach @mcts. Furthermore, short-term profit may often be outpaced by an
opponent's stronger tactical play. With the introduction of MCTS into the field
of Computer Go, programs became
improved significantly. 

In Go on a 9 #math.times 9-board, a 5 dan professional player was
beaten by MoGo in 2007; in 2009, a 9 dan professional by Fuego @mogo. In the course of
pure MCTS applied to Go on a 19 #math.times 19-board, various models managed to
defeat high-ranking professional players, albeit with up to 9 handicap stones,
and gained a ranking of 4 dan on online play.





== Deep Learning

=== The Alpha-Models
There are multiple named training runs of AlphaGo, each improving on the
previous.
"AlphaGo Fan", which was the program to win against a human professional on a $9
times 9$ board, won $5$-nil @alphago. "AlphaGo Lee Sedol" won against 
Lee Sedol with a
record of $4-1$. The last iteration, "AlphaGo Master", won against top human 
professionals in online games with a record of $60-0$ @alphagozero. 
When these models were 
compared to AlphaGo Zero, their
Elo ratings were $3,144$, $3,739$, and $4,858$, respectively. AlphaGo Zero
received a rating of $5,158$ @alphagozero.

AlphaZero is another iteration on this self-play algorithm @alphazero. While ultimately the
same structure as AlphaGo Zero, the domain-specific optimisation that Go is
rotationally invariable is removed which reduces the amount of data of data
available for this game. On the other side, this allows AlphaZero to be used for
more games than just Go.

AlphaZero managed to beat state-of-the-art models in chess (Stockfish), shogi
(Elmo), and Go (AlphaGo Zero).


=== MuZero
MuZero is a generalisation of the Alpha-family @muzero. While previous models required a
working model of the environment, MuZero is capable of learning about the
environment through interaction with the environment. While also achieving
similar results on traditional games such as Go and chess, it is also capable of
learning to play real-time games like Atari. In all of these domains, it was
capable of surpassing state-of-the-art models and therefore top human
professionals.

=== Gumbel AlphaZero
Google DeepMind's successor model, Gumbel AlphaZero, breaks from traditional
MCTS using UCB , the basis for UCT @uct, or variants, and
instead makes use of other policy improvement strategies @gumbelzero.
One such strategy is sequential halving, in which the window of considered moves
is halved considering from the highest-rated moves.

=== Further research
==== KataGo
KataGo represents a significant step to the wider Computer Go community @katago. 
While
similarly strong models such as FineArt, a proprietary Chinese model, or
LeelaZero, a "fairly faithful reimplementation" of the original AlphaGo Zero
model @leelazero, exist, 
KataGo is an open-source 
model employing additional strategies.
Improving on the architecture and
process of AlphaZero, KataGo introduces and publicly explains several
domain-dependent and -independent additions to improve efficiency,
flexibility, and utility for human analysis.

Some of these features include:
- Auxiliary policy targets: In addition to simply predicting the best move for
  the current board position, KataGo also predicts the opponent's move.
- Playout cap randomisation: Most board positions are searched with a low number
  of simulations and only used to train the value head, the head that evaluates
  the likely winner of the position. Long playouts are then
  used for policy training.
- Blocking overplay: Forbidding playing in a certain region after a number of
  moves contributes in efficiency, albeit little in regard to performance.
- Auxiliary ownership and score targets: The network also predicts to whom an
  intersection belongs as well as a estimations of the point difference at the
  end of the game.

==== Dynamic MCTS
Forming a basis for this thesis, Lan et al. introduced
estimations of uncertainty at intervals during training, to determine whether
continued search is necessary @d_mcts. As MCTS finds the optimal move after 1
simulation 62% of the time, and most positions require far less than the
maximal number to find the optimal move, it is permissible to explore fewer situations. 
Thus, if there is founded certainty that the best
move has been found, search should terminate.
// - Monte Carlo Graph Search (MCGS): A notable advancement where the search tree
//   is generalized into a Directed Acyclic Graph (DAG). This allows the AI to
//   recognize transpositions—different sequences of moves that lead to the
//   identical board state—significantly reducing redundant computations on the 9x9
//   board.
// - Terminal Solvers: Since 9x9 Go is a smaller domain, some implementations
//   integrate "mini-max" style terminal solvers within the MCTS leaves. If a
//   branch can be proven as a win or loss through exhaustive search, the result is
//   backpropagated immediately, pruning the tree.
// - Warm-Start MCTS: Researchers have experimented with using classical heuristics
//   (like RAVE) to "warm-start" the MCTS during the early stages of AlphaZero
//   self-play training, mitigating the high failure rate of agents starting with
//   purely random weights.

= Methodology
In the following, possible heuristic approaches to dynamically lower the number 
of MCTS simulations will be presented. These methods will be trained separately
for individual networks. The resulting models are evaluated by matching them
against each other to study playing strength and
the actually used number of MCTS-simulations.


== Reasoning 9 #math.times 9 vs. 19 #math.times 19
A $9 times 9$ board has a state-space complexity of $3^81 approx 4 times 10^38$,
of which $23.43% approx 1.04 * 10 ^ 38$ @combinatorics
are legal. 
In contrast, a $19 times 19$ board has $3^(19 times 19) approx 1.74 * 10^172$ 
possible positions and $2.082 times 10^170$
 legal positions . Thus,
in an effort to gain comprehensive results within the hardware and temporal limits
of this thesis, the board size is restricted to $9 times 9$.


== Choosing AlphaZero Over Alternatives
The basic AlphaZero structure is used as the baseline in this work for reasons
of clarity and experimental control.
Although models such as KataGo achieve state-of-the-art performance @katago, 
it does so by
incorporating a wide range of engineering optimisations, training heuristics,
and system-level improvements. As a result, isolating the effect of
modifications within such a system can be difficult, since performance gains may
arise from interactions with existing components rather than the modification
itself. 

Despite the relative successes of the Gumbel models compared to their PUCT-based
predecessors @gumbelzero, the PUCT-based model still remains a widely employed
approach in popular Go models @katago.




== Environment 
=== Base Implementation
The primary research tool for this thesis is Michael Hu's implementation
@alpha_hu. It provides a robust implementation of the AlphaZero algorithm with
native support for Go using the Chinese ruleset and tools for model analysis. It 
is fully written in Python and relies on PyTorch.


=== Computational Resources: University HPC Cluster
Due to the high computational cost of self-play reinforcement learning, all
training and evaluation experiments are conducted on 
Osnabrück University’s High-Performance Computing (HPC) Cluster #footnote[Project
number of the HPC: 456666331].

The cluster provides multiple GPU-enhanced nodes. Each relevant node includes
- 4 NVIDIA A100 GPUs,
- 128 AMD EPYC CPUs, and
- 927.7 GB of memory.
Resources are managed by the SLURM workload manager operating on Rocky Linux 8.5.




== Heuristics
The heuristics suggested here are based on the idea, that the network's
predictions is able to
express an inherent certainty that can be leveraged to adjust
the amount of simulation needed to generate a successful training sequence while
lowering the computational efforts.

Here, MCTS augmented with predictors and heuristics uses the reference number of
simulations to recalculate a new number of simulations. These calculations and
their rational are explained in the following.



=== Entropy of Likeliest $k$ Actions
The goal for this heuristic, #topk, is to calculate the entropy of the $k$ 
highest-rated
moves of the predictor's move probability distribution and adjust the amount of
simulations accordingly.

Entropy is by itself a measure of uncertainty for a distribution of
probabilities. The use of the entropy is therefore an apparent possible solution
to the goal of this thesis. Furthermore, using the $2$ likeliest options of a
probability
distribution is a common approach to gather a measure of certainty of that
distribution. Increasing this window of consideration should give a more
balanced view.

The important formulas are
$ H_"norm" = frac(H("Top"k),ln(k)), $
$ n_"new" = n_"base" dot frac(2, 1+e^(-s(H_"norm"-s p))) $ <ent_eq>
where 
- $H("Top"k)$ is the entropy of the $k$ highest ranked moves of $pi$ that are
  sorted descendingly in $"Top"k$.
- $H_"norm"$ is the result of re-normalising the entropy of these moves to
  within the range $[0,1]$,
- $n_"new"$ is the applied number of simulations, 
- $n_"base"$ is the baseline number of simulations,
- $s$ is the steepness of the graph, and
- $s p$ is the position of the inflection point on the $x$-axis.

@ent_eq, represented in @log_graph, is a logistic function. 
The formula here will continue to be used with $s = 8$ and $s p = 0.5.$
The graph is maximised at $frac(2,
1+e^(-8(1-0.5))) approx 1.964$ 
and, because $H$ is
normalised, it is minimised at $frac(2, 1+e^(-8(0-0.5))) approx 0.036$.
These values should allow the entropy of the $k$ highest-rated moves
to transition
fluidly around the inflection point at $0.5$. 

#figure(
  plot(
    xmin: -0.5, xmax: 1.5,
    ymin: 0, ymax: 2,
    width: 3, height: 3,
    xlabel: $x$,
    ylabel: $y$,
    show-grid: true,
    (fn: x => (2 / (1 + calc.exp(-8 * (x - (1/2))))), 
      stroke: gray + 1.5pt,
      label: $frac(2, 1+e^(-8(x-0.5)))$,
      label-pos: 0.5,
      label-side: "below-right",
    ),
  ),
  caption: [Logistical uncertainty function for high-rated moves' entropy.]
) <log_graph>

Effort for this heuristic should be negligible. The algorithmic complexity
of finding the highest-sorted is $"O"(|A| dot log k)$, with $|A|$ as the space of
all actions. There also is the additional cost of calculating the entropy of
$"Top"k$.







=== Comparison of High And Low Ranking Moves
This heuristic, #topbotk, measures the disparity between the probability 
densities of the
$k$ highest-rated
moves and the $A-k$ lowest-rated moves. Using this distance,
the number of simulations is adjusted.

The above heuristic has a strong focus on relatively few high-rated moves
compared to the overall space of possible moves. This increases vulnerability to
overconfidence where it is not warranted. That is especially the case when a
single move is disproportionately well-rated. Therefore, one solution to this
problem can be
a more global consideration of the move probability space.

$ d = sum_(a in "Top"k)pi(a) - sum_(a in A without "Top"k)pi(a), $
$ n_"new" = n_"base" dot 2/(1+e^(s(d - s p))), $ <den_eq>
where
- $pi(a)$ is the probability of $a$ in $pi$,
- $"Top"k$ is the array of the highest-rated $k$ actions.

@den_eq is similar to @ent_eq with the entropy exchanged for the difference of
the probability densities and the sign of the slope $s$ flipped.

#figure(
  plot(
    xmin: -0.5, xmax: 1.5,
    ymin: 0, ymax: 2,
    width: 3, height: 3,
    xlabel: $x$,
    ylabel: $y$,
    show-grid: true,
    (fn: x => (2 / (1 + calc.exp(8 * (x - (1/2))))), 
      stroke: gray + 1.5pt,
      label: $frac(2, 1+e^(8(x-0.5)))$,
      label-pos: 0.5,
      label-side: "below-right",
    ),
  ),
  caption: [Logistical uncertainty function for High/Low Comparison.]
) <hl_log_graph>



This solution should be able to help mitigate the inequal consideration of moves
from the first heuristic. Computational effort consists of the sorting in $O(n
log k)$ and the addition. Therefore the effort should be about as much as for
the first heuristic.



=== Auxiliary Head Estimating Uncertainty 
Lan et al. introduced supplementary networks to estimate certainty and stop
searching when reaching a certain threshold. However,
as merging networks for predicting value and policy has proved successful
previously, 
enabling the network to predict its own prediction-search disagreement should also 
turn out beneficial. 
In this heuristic, #rl, the predictor network $f$ on board position 
$s$ will return
$ f(s)=(bold("p"),v, u), $ where 
$bold("p")$ is the move probability distribution, $v$ the evaluation, and $u$
the uncertainty estimation. 
The number of simulations is adjusted according to
the formula
$ n_"new" = n_"base" dot exp(u). $
This means that higher uncertainty correlates with searching more thoroughly correlates
while less uncertainty correlates with a lower number of simulations. The
exponential function allows both to increase and decrease the number of
simulations. $n_"new"$ also is limited to a maximal number to
stop the search from going unendingly long.



The loss will be calculated using the expression
$ l_"all" = l_"az" + c dot (u - lambda dot tau(bold("p"), pi))^2, $
where
- $l_"az"$ is the error signal used by AlphaZero considering $(bold("p"), 
sigma, v, theta))$,
- $c$ is a weighting constant for MSE,
- $tau(bold("p"), pi)$ is the KRCC of board state $s$,
- $lambda$ is a scaling constant for the KRCC, and
- $pi$ is the distribution found by MCTS.
In this context $tau(bold("p"), pi)$ measures the similarity between the ranked
move
distribution estimated by the prior and the ranked move distribution determined
by MCTS.



This heuristic should be capable of reducing the average simulation numbers by
predicting how much move estimations change during MCTS in different positions.
However, especially the process can be very time-intensive in the beginning of a
single game when more moves are available and the calculation of KRCC requires
more effort.


While the idea is promising, a glaring problem with this approach is the
computational cost of calculating the KRCC for the two distributions. One
solution is to similarly to the above heuristics consider only the highest $k$
actions. This is also looked at in the following sections.

=== Random
Following the example of Wu et al. @katago, a uniformly chosen number from $n in [1,
#max_number]$ will be used as the number of playouts for MCTS
in order to investigate in comparison whether these
strategies actually fulfill their purpose
and have an active part in lowering computational effort in this heuristic,
#rand. If randomly adjusting
the amount of simulations for MCTS
performed equally well as the strategies suggested above and assuming that they
all perform similarly well to the base line model, this would
suggest that the strategies constitute unnecessary computational effort.

== Evaluation
After the models are trained, they play 20 games against each other
to evaluate playing strength. The models also record the number of
simulations executed from MCTS during training as well as test-play to enable
comparisons between computational effort spent.

= Results
Of the resources provided by the HPC,
- 1 NVIDIA A100 GPU,
- 32 AMD EPYC CPUs, and
- 150 GB of memory
are requested for each individual training run. For the duration of 24 hours, 
28 threads simultaneously play games to collect training data. The fixed number of
simulations is 200 either as the hard number for the base version or as
reference for the heuristic methods.


#let data = csv("ergebnisse/data.csv")
#let header = data.at(0)
#let rows = data.slice(1)

#let row_names = ("Played games", "States", "Simulations", "Median sim's", "Sim's per move")

#figure(
  align(center)[
    #table(
      columns: (10em, ..((8em,) * (header.len()))),
      // header row
      table.header(strong(""), ..header.map(h => strong(h))),
      // data rows with names prepended
      ..rows.enumerate().map(((i, row)) => (row_names.at(i), ..row)).flatten()
    )
  ],
  caption: "Results of training"
)

Model #rl shows a far longer larger collection of games as compared to base
#van. However, the number of researched states is far lower than for #van.








= Discussion




There are many issues that can be raised against this project. First, only one
training run for each variation of AlphaZero has been executed. Furthermore,
training data was sparse because of the short time of training.

Another issue that needs to be raised here,
is that it cannot be conclusively proved that #check([equal]) performance while
#check([lower]) simulation cost is due to the methods suggested here. To answer
this question, randomised numbers of simulations in the appropriate range could
be used.

Nonetheless, these results do give reference points that models can be allowed
to predict their own certainty to increase efficiency within a certain context.
For example, at the highest level of play, even small errors can lead to a loss
of the match. 


= Conclusion








#pagebreak()
#bibliography("text/sources.yml", style: "ieee")

#show: appendix
// #pagebreak()
// = Go Terms
// To fight is to play locally to.
//
// Life-and-death-situations are local problems in which two or more groups
// compete for life.
