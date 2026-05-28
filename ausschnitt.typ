#set text(font:"Open Sans", size:11pt, hyphenate: false)
#set par(justify: true, leading: 1.5em)
#set heading(numbering: "1.1")
#show math.equation.where(block: false): box
#set math.equation(numbering: "(1)")

#let fill(txt) = underline(text(red, weight: "bold")[FILL #txt])
#let check(txt) = underline(text(blue, weight: "bold")[CHECK #txt])
#let cite = underline(text(green, weight: "bold")[CITE HERE])

#import "@preview/simple-plot:0.3.0" : plot

#import "@preview/lets-go:0.1.0": go-board, go-board-9
#import "@preview/algorithmic:1.0.7"

#set page(numbering:"1")

#let max_number = 300

== Heuristics
The heuristics suggested here are based on the idea, that the prior is able to
express an inherent certainty that can be leveraged to adjust
the amount of simulation needed to generate a successful training sequence while
lowering the computational efforts.



=== Entropy of Likeliest $k$ Actions
The goal for this heuristic is to calculate the entropy of the $k$ highest-rated
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
  caption: [Logistical uncertainty function]
) <log_graph>

Effort for this heuristic should be negligible. The algorithmic complexity
of finding the highest-sorted  $"O"(|A| dot log k)$, with $|A|$ as the space of
all actions. There also is the additional cost of calculating the entropy of
$"Top"k$.

Making use of more values of that distribution should also provide
a clearer estimation of certainty, differences are discussed in a later section.







=== Comparison of High And Low Ranking Moves
This heuristic measures the disparity between the probability densities of the
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
$ n_"new" = n_"base" dot (2/), $ <den_eq>
where
- $pi(a)$ is the probability of $a$ in $pi$,
- $"Top"k$ is the array of the highest-rated $k$ actions,
- $A$ is the space of all possible actions.

@den_eq is the same as @ent_eq with the entropy exchanged for the difference of
the probability densities.



This solution should be able to help mitigate the inequal consideration of moves
from the first heuristic. Computational effort consists of the sorting in $O(n
log k)$ and the addition. Therefore the effort should be about as much as for
the first heuristic.

Differences in $k$ here will also be discussed in a later section.



=== Auxiliary Head Estimating Uncertainty 
Lan et al. introduced supplementary networks to estimate certainty and stop
searching when reaching a certain threshold. However,
as merging networks for predicting value and policy has proved successful
previously, 
enabling the network to predict its own prediction-search disagreement should also turn
out beneficial. 
The predictor network $f$ on board position $s$ will return
$ f(s)=(bold("p"),v, u), $ where 
$bold("p")$ is the move probability distribution, $v$ the evaluation, and $u$
the uncertainty estimation. 
The number of simulations is adjusted according to
the formula
$ n_"new" = n_"baseline" dot exp(u). $
This means, that searching more thoroughly correlates with higher uncertainty
while a lower number of simulations correlates with less uncertainty. The
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
and have an active part in lowering computational effort. If randomly adjusting
the amount of simulations for MCTS
performed equally well as the strategies suggested above and assuming that they
all perform similarly well to the base line model, this would
suggest that the strategies constitute unnecessary computational effort.

#pagebreak()
#bibliography("text/sources.yml", style: "ieee")
