---
title: Modeling the Effectiveness of British Columbia Fire Control
author: Andrew Bekcer and Brendan Whitney
---

A PDF of our report can be found [here](report.pdf).
All code can be found on [our repository](https://github.com/brendanwhit/MoCS-final-project).

## Introduction

Forest fires are destructive events that can decimate towns,
destroy roads,
and can be very costly.
Understanding and developing best practices to minimize the impact of forest 
fires on man-made communities
and infrastructure is of paramount importance in threat of increasing forest
fire potential driven by climate change[1].
Using the British Columbia Wildland Fire Management Strategy 
(WFMS)[2] as a guideline,
we created a model of best practice fire risk reduction techniques.
The model used multiple strategies and combinations of budget constraints to 
analyze the most effective combination of strategies to handle three different
wind scenarios.

Following decades of the dominant forest fire fighting strategy of extinguish 
every fire, forests have become more distinctly old growth with more surface
litter[2].
This surface litter contains the fuel to potentially ignite large forest fires.
Excess surface litter has been shown to significantly increase the scorch height of fires,
which directly leads to more trees catching fire[3].
Once trees begin to light,
the potential scope of the fire drastically increases due to the large fuel source provided by trees.
The WFMS indicates multiple strategies for reducing the fuel load in susceptible forests.
The strategies mentioned are
forest thinning,
wood mastication,
and controlled burning.
The model groups forest thinning and wood mastication together as physical fuel management,
and leaves controlled burning as a different management practice.

Wind is a crucial ingredient in the forest fire equation,
especially for determining the speed of fire propagation.
Studies of grassland fires in Australia revealed that the most important factor to explain the variation
among fire spreading patterns and size was the wind speed at 2 meters[4].
Wind was an important feature in machine learning algorithms to predict the susceptibility of certain
forest patches to ignition[5].
The ability of a fire to "jump" fire breaks is largely determined by the amount of wind present,
and represents a fundamental problem when using controlled burns for fuel management.

The WFMS proposes multiple strategic goals concerning controlled burns.
The first goal mentions the dangers of using controlled burns in a close vicinity to communities,
infrastructure, 
or high value resources.
The second goal indicates the benefits of using controlled burns as a fuel management practice for less
developed locations under ideal conditions.
The strategy does not indicate the exact nature of the ideal conditions for controlled burns,
but there is evidence to support the use of controlled burns during the spring to reduce the percentage of 
complete burns[3].
Controlled burns can be effectively modeled using traditional forest fire models to ensure the burn does not become unmanageable over the course of its life[6].
WFMS does not allow for controlled burns without extensive research and predictive modeling to determine the safety of a particular burn.

## Model

The model is a cellular automata (CA) with 5 states, or 6 states for the
iterations of the model with the town in the center.  The model simulates
forest growth, management, and fire spread on two different time scales. The
forest growth and management happen on the same time scale, where the forest
grows and is subsequently managed using two practices, understory clearing and
controlled burns. Both forest growth and management stop when are fire begins.
This break in scaling represents the idea that forests grow in the time scale
of years while fires spread on the time scale of weeks. Expansions of the
states, rules, and assumptions are in the following subsections.

### States

The five states of the base model are:
+ No Tree (NT)
+ Tree with no understory (T)
+ Tree with understory (UT)
+ Tree on fire (TF)
+ Understory on fire (UF)

### Rules

The rules for our model fall into three categories: Update Rules, Forest
Management, and Wind Rules.  Further explanations of the three rules are
explained in the following three subsections.  The general schematic for
updating our forest fire model is:
+ Grow Forest
+ Manage Forest
+ Simulate Fire (if any)
Fire simulation can occur at two points.  We will simulate controlled burns
first, then implement random lightning strikes to see if any uncontrolled fires
appear.  The only difference between controlled burns and uncontrolled burns is
the removal of probabilities relating to the chance of a tree catching fire
from the understory.  For controlled burns, every understory fire becomes a 
tree fire, and thus returns the entire connected understory component back to
ashes.  For uncontrolled burns, this event occurs with a certain probability,
which is specified in the Update Rules section.

#### Update Rules

The majority of rules for our model are stochastic, however a couple of them
are deterministic. The stochastic rules are:
+ Tree growth (random): NT &rarr; T with p<sub>TG</sub>
+ Tree growth (neighbor): NT &rarr; T with N<sub>neighbors</sub> &sdot; p<sub>NTG</sub>
+ Understory growth: T &rarr; UT with p<sub>UG</sub>
+ Understory catches fire (lightning): UT &rarr; UF with p<sub>l</sub>
+ Understory fire burns out: UF &rarr; T with p<sub>&beta;</sub>
+ Understory continues burning: UF &rarr; UF with p<sub>&gamma;</sub> 
+ Understory fire starts tree fire: UF &rarr; TF with 1-p<sub>&beta;</sub>-p<sub>&gamma;</sub>
+ Tree catches fire: T &rarr; TF with 1-p<sub>&alpha;</sub> adjusted for wind level
The deterministic rules:
+ Tree fire burns out: TF &rarr; NT
+ Understory catches fire (fire spread): UT &rarr; UF if neighboring TF or UF
We used the following transition probabilities for the stochastic processes:
+ p<sub>TG</sub>=0.0005
+ p<sub>NTG</sub>=0.1
+ p<sub>UG</sub>=0.1
+ p<sub>l</sub>=3/n&sup2;
+ p<sub>&beta;</sub>=0.4
+ p<sub>&alpha;</sub>=0.5
+ p<sub>&gamma;</sub>=0.2

### Management Algorithms

#### Forest Management

For allocation of resources to forest management, we implemented a top-down
strategy. Therefore, for both undergrowth clearing and controlled burns, the 
largest area of forest to which the cost of managing does not exceed the budget
is managed first.  Then the remaining budget is reallocated to the next largest
parcel not exceeding the budget, and so on.  Both types of forest management
have upper and lower bounds on the size of forest parcel they can be applied
two, giving two disjoint sets.

Undergrowth clearing is a more labor intensive job that requires human labor on
each parcel to be cleared. Therefore, undergrowth clearing is best for smaller
parcels of forest, especially those near important structures where burns could
cause harm. The minimum cutoff for forest clearing requires a connected area of
understory of size 10. The maximum size that can be cleared using this strategy
is 30. Due to the lack of completely cutting down and removing trees in the
undergrowth clearing mechanism, the cost of undergrowth clearing is 0.5 per
unit cleared.  Thus, the minimum cost for a clearing is 5, and the maximum cost
is 15.

For controlled burning, the lower cutoff of connected component size is 31 and
the upper cutoff is determined by budget constraints.  The implementation of 
controlled burns consists of first creating a fire break by removing every 
single tree that surrounds the connected component of trees with undergrowth.
The cost of this fire break is 2 per unit to reflect the increased cost of
cutting down and completely removing trees.  Once the fire break has been
created, the cost of starting the controlled fire is 5, which is a reflection
of the planning and research required for a successful controlled burn.  The 
upper cutoff is a balance between the available budget and how many trees must
be removed in order to create a successful fire break.

#### Wind

The probability of neighboring trees and understory catching on fire for our
model is adjusted by the level of wind. We simulate wind, by adjusting the
number of "neighbors" a particular tree has. This creates the effect that fire
would be able to jump over areas regardless of the designation of those areas.

To simulate no wind, we used just ordinal neighbors to adjust the probability 
of a tree catching on fire given the number of neighbors that are on fire. The
3x3 matrix below represents the weights given to each neighbor:
\[
\begin{bmatrix}
0 & 1 & 0 \\
1 & \textcolor{red}{0} & 1 \\
0 & 1 & 0 
\end{bmatrix}
\]
For our model, every tree in an ordinal direction has an equal chance in
lighting the tree in question, designated by the red text, on fire. 

To simulate low wind conditions, a 5x5 matrix was used with more weight given 
to the neighbors west of the trees.  The wind matrix is applied to every tree 
in the same orientation, thus simulating a prevailing west to east wind across
the scope of our model. The 5x5 matrix used to simulate low wind conditions is
below: 
\[
\begin{bmatrix}
0&\frac{1}{10}&0&0&0\\
\frac{1}{10}&\frac{1}{5}&1&0&0\\
\frac{1}{5}&2&\textcolor{red}{0}&\frac{1}{2}&0\\
\frac{1}{10}&\frac{1}{5}&1&0&0\\
0&\frac{1}{10}&0&0&0\\
\end{bmatrix}
\]
With high winds, a tree will be 2 times more likely to catch fire if its direct
westerly neighbor is on fire than if its direct easterly neighbor is on fire. 
Additionally, trees two spaces to the west of the potential ignition point 
begin to factor into the probability of lighting on fire.

To simulate high wind conditions, a the same 5x5 matrix was used with even more
weight given to the neighbors west of the trees.  The wind matrix is applied to
every tree in the same orientation, thus simulating a prevailing west to east 
wind across the scope of our model. The 5x5 matrix used to simulate high wind
conditions is below: 
\[
\begin{bmatrix}
0 & \frac{1}{2} & 0 & 0 & 0 \\
\frac{1}{2} & 1 & 2 & 0 & 0 \\
1 & 3 & \textcolor{red}{0} & 1 & 0 \\
\frac{1}{2} & 1 & 2 & 0 & 0 \\
0 & \frac{1}{2} & 0 & 0 & 0
\end{bmatrix}
\]
With high winds, a tree will be 3 times more likely to catch fire if its direct
westerly neighbor is on fire than if its direct easterly neighbor is on fire. 
Trees two spaces west factor much more into the probability of the central tree
igniting than in the low wind model.

### Assumptions

Our model uses several assumptions to simplify the coding.
+ Only the understory can catch fire from lightning strikes.
+ Understory will always catch fire from neighboring understory that is on fire.
+ We only considered the four cardinal neighbors (North, East, South, West) for
neighbor interaction, only for when excluding the effect of wind.
+ Trees can only catch fire from neighboring trees, or from understory that is
on fire under the tree.
+ Trees grow randomly on no tree places instead of clumping

## Results

Under these assumptions and rules we simulated and analyzed both a situation
where our outcome was fire size and a situation where we were concerned with 
preventing fire from reaching a central location. By looking at both of these
situations we can begin to understand how both wind and resource allocation 
with regards to forest management effect forest fire dynamics. If these 
outcomes match with observed outcomes, it is indicative that out model 
reasonably models real-world forest fires.

### General Fire Dynamics

In order to determine the dynamics of forest fires in general conditions the
algorithms described above regarding understory clearing and controlled burns
were applied to a 200&sdot;200 cell map and allowed to play out across a long
period of time. From that we were able to determine average wildfire size,
percentage of timesteps with burns, percentage of timesteps with large burns 
(Over 200 cells), and percent of controlled burns which extended outside of 
their intended range (OoC Burns). This is all summarized in Table 1.
Note that in % Burns, 100% means that both a controlled burn and a wildfire,
which same as saying twice as many burns occurred as there were timesteps.

\begin{center}
\begin{tabular}{c c c c c c}
Wind & Budget & Avg. Wildfire Size & % Burn & % Lg. Burn & % OoC Burns\\
\hline
     No & All Burn & 1932 & 77% & 19.5% & 0%\\
     No & All Clear & 4845 & 16% & 8.5% & N/A\\
     No & 50/50 & 3312 & 59.5% & 15.5% & 0%\\
     No &  25% C, 75% B & 3634 & 58.5% & 14% & 0%\\
     No & 75% C, 25% B & 4011 & 60% & 11.5% & 0%\\
     Low & All Burn & 263 & 63% & 29.5% & 45%\\
     Low & All Clear & 4096 & 18% & 11.5% & N/A\\
     Low & 50/50 & 1556 & 40.5% & 30% & 41%\\
     Low &  25% C, 75% B & 335 & 58%&40.5% & 70%\\
     Low & 75% C, 25% B & 1625 & 30.5%& 22%& 30% \\
     High & All Burn & 129 & 53% & 4.5% & 6%\\
     High & All Clear & 6078 &8.5% & 6.5% & N/A\\
     High & 50/50 & 2515 &16.5% &12.5% &13%\\
     High &  25% C, 75% B & 422 & 42% & 26.5% &47%\\
     High & 75% C, 25% B & 1944 &18% & 12.5% &14%
\end{tabular}
\captionof{table}{Results of simulations of forest fires in differing wind conditions.}
\label{tab:fire}
\end{center}

### Adding a Town

In addition to exploring how fire dynamics change under differing management 
techniques and levels of wind, we added a centrally located 'town' composed of
4 cells which we attempted to protect. In order to do this we added a fifth and
sixth state to our cellular automata, the fifth being buildings, and the sixth 
being burnt buildings. This also involved adding one more stochastic rule about
the likelihood of these buildings burning. This is that a building will
transition to a burnt building if the sum of the fires in adjacent (or
windblown) cells is above a random uniform number between 0 and 1. This means
that if there is one adjacent fire, a building will burn, but in windblown 
conditions a single burning tree over a block away is not necessarily going to
burn a building. Additionally buildings do not ignite other buildings, which 
allows us to determine subtle differences in the effectiveness of management 
strategies.


In addition to this new rule we modified how both controlled burns and 
undergrowth clearing was implemented. In an area up to 8 cells away from the
town clearing was conducted, and in an area between 8 and 30 cells away from
the town controlled burns were conducted. In [2]
the guidelines mention that controlled burns should not be conducted where
humans are living, so we chose to only conduct land clearing in those areas, 
and then controlled burns further from the town squares. The algorithms are the
same except the only consider the area inside of these regions.

The results from simulations are summarized in Table~\ref{tab:town}. Five
different budgets allocating differing amounts of 'money' to either controlled
burning or land clearing are compared across the three wind conditions. The
simulations were run either until the whole town burnt, or 200 years of 
simulated forest growth and management occurred. In the case of low wind, the
most variable of the three cases, we averaged over several runs of 200 years.

\begin{center}
\begin{tabular}{c c c c}
Wind & Budget & Time to End & Outcome\\
\hline
     No & All Burn & 40 yrs & Town Burnt\\
     No & All Clear & 200 yrs & 75% Burnt\\
     No & 50/50 & 200 yrs & No Town Burnt\\
     No &  25% C, 75% B & 200 yrs & No Town Burnt\\
     No & 75% C, 25% B & 200 yrs & No Town Burnt \\
     Low & All Burn & 40 yrs & Town Burnt\\
     Low & All Clear & 52.5 yrs & Town Burnt\\
     Low & 50/50 & 195 yrs &  54% Burnt\\
     Low &  25% C, 75% B & 137 yrs & 92% Burnt\\
     Low & 75% C, 25% B & 40 yrs & Town Burnt \\
     High & All Burn & 10 yrs & Town Burnt\\
     High & All Clear & 10 yrs & Town Burnt\\
     High & 50/50 & 10 yrs & Town Burnt\\
     High &  25% C, 75% B & 10 yrs & Town Burnt\\
     High & 75% C, 25% B & 10 yrs & Town Burnt \\
\end{tabular}
\captionof{table}{Numerical results of simulation of town indicating the status of the town, the wind conditions, and how long the town survived.}
\label{tab:town}
\end{center}


## Discussion

From our results we can make a few straightforward conclusions: high levels of 
wind mean that controlled burns are a bad idea, and that forest management is 
simply more difficult. We also can see that a combination of both controlled
burns and forest clearing is most effective at protecting a particular location
from wildfires. In particular we can see from our results at low wind levels
that there's a balancing point where we have the best outcomes overall. Note
that just because this appears at 50% allocation to both controlled burns and
clearing that does not mean that it's actually at this point. It is likely that
our estimates for relative cost are off, and as a result these percentages are
off as well. What we can say is that both forest understory clearing close to a
town and controlled burns further away are important for the long term safety 
of a town. Implementing any single one of these methodologies without the other
is unlikely to be effective at preventing fire damage in the long term, and
doesn't sufficiently reduce forest fire size overall.

We can see that the most difficult situation is trying to control wildfires in
areas with frequent high winds. These frequent high winds result in fires being
able to jump significant distances, over either man-made or natural firebreaks.
This presents in Table~\ref{tab:fire} in the high wind condition by more 
extreme levels in the average fire size. In the 'all burn' high wind condition 
we see a misleadingly low level of controlled burns being out of control
because all of them are out of control. This means we have many controlled 
burns every day and each one is burning more than the intended area, but it is 
consistently below our boundary criteria used to define percentage. 
Additionally we have very few large fires in the 'all clear' high wind
condition, but the average fire size is over 6000, which represents 15% of the
total cells on the map.

These dynamics seem to follow what we expect both from the WFMS[2] and the 
paper on Australian brush fires [4]. Higher winds 
result directly in larger fires when we don't increase the rate of fire 
occurrence through controlled burns, and controlled burns become much less 
favorable as winds increase. Additionally when managing a forest a mixture of 
both under story clearing, either through mastication and thinning, and 
controlled burns are necessary to effectively protect structures. This is not
an unsurprising result, but an indicator that similar agent-based models or 
cellular automata could be used for accurate modeling of real world wildfire 
management techniques.

## Bibliography

[1] B. J. Stocks, M. Fosberg, T. Lynham, L. Mearns, B. Wotton, Q. Yang, J. Jin,
K. Lawrence, G. Hartley, J. Mason, _et al._, "Climate Change and Forest Fire
Potential in Russian and Canadian Boreal Forests," _Climatic Change_, vol. 38,
no. 1, pp. 1-13, 1998

[2] B. W. Service, _Wildland Fire Management Strategy_, Government of B.C.,
Canada, Sep 2010

[3] E. E. Knapp and J. E. Keeley, "Heterogeneity in Fire Severity Within Early
Season and Late Season Prescribed Burns in a Mixed-conifer Forest," 
_International Journal of Wildland Fire_, vol. 15, no. 1, pp. 37-45, 2006.

[4] N. Cheney, J. Gould, and W. Catchpole, "The Influence of Fuel, Weather, and
Fire Shape Variables on Fire-spread in Grasslands," _International Journal of 
Wildland Fire_, vol. 3, no. 1, pp. 31-44, 1993.

[5] Z. S. Pourtaghi, H. R. Pourghasemi, R. Aretano, and T. Semeraro, 
"Investigation of General Indicators Influencing on Forest Fire and Its 
Susceptibility Modeling Using Different Data Mining Techniques," _Ecological
Inidicators_, vol. 64, pp. 72-84, 2016.

[6] E. Pastor, L. Z&aacute;rate, E. Planas, and J. Arnaldos, "Mathematical
Models and Calculation Systems for the Study of Wildland Fire Behaviour," 
_Progress in Energy and Combustion Science_, vol. 29, no. 2, pp. 139-153, 2003.
