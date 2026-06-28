#set text(font:"Open Sans", size:11pt, hyphenate: false)
#set par(justify: true, leading: 1.5em)
To analyze the impact of training experience and search effort on model
performance, five models were trained using a self-play reinforcement learning
framework. Each model was trained for a predefined amount of time, during which
self-play games were continuously generated and used to improve the underlying
neural network. Consequently, the total number of self-play games completed
during training varied across models. In addition, the models differed in the
number of simulations performed by the search algorithm at each decision point.

Model A was trained for *X* hours, during which it generated 100,000 self-play
games and executed 50 simulations per move. Model B was trained for *Y* hours,
resulting in 250,000 self-play games and 100 simulations per move. Model C was
trained for *Z* hours and completed 500,000 self-play games while employing 200
simulations per move. Model D was trained for *W* hours, generating 1,000,000
self-play games and performing 400 simulations per move. Finally, Model E was
trained for *V* hours, during which 2,000,000 self-play games were produced and
800 simulations per move were executed.

By varying both the training duration and the search budget, this experimental
setup enables an investigation of how the amount of self-play experience and
computational search effort influence the quality of the learned policy and the
overall playing strength of the resulting models.



The evaluation results show that Models A and B achieved the strongest
performance among the examined configurations. While Model A served as the
baseline, it remained competitive against all subsequently developed models and
outperformed Models C, D, and E. This finding suggests that increasing the
computational budget beyond the baseline configuration does not necessarily
translate into improved playing strength.

Model B achieved the highest overall performance and therefore represents the
most successful configuration evaluated in this study. In contrast, the
additional search effort employed by Models C, D, and E did not result in
further performance gains. Instead, the results indicate diminishing returns
with respect to increasing search budgets and training complexity.

Overall, the findings demonstrate that moderate search budgets, as employed by
Models A and B, were sufficient to achieve strong performance, whereas larger
computational investments yielded limited additional benefits.
