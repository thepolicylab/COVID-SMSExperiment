"""
The implemenation of the ε-bounded Thompson sampler
"""
from typing import List, Optional, Tuple, Union

import numpy as np
from scipy import stats as st


def draw_posterior_theta(
    num_successes: int,
    num_failures: int,
    num_draws,
    seed: Optional[Union[int, np.random.mtrand.RandomState]] = None,
) -> np.ndarray:
    """
    Given a number of past successes and failures, draw `num_draws` from the
    associated posterior distribution for a particular arm. Here

        π(α, β) ∝ (α + β)^{-2.5}
        p ~ Beta(α, β)
        x ~ Bernoulli(p)

    Args:
        num_successes: the number of successes for this arm
        num_failures: the number of failures for this arm
        num_draws: the number of draws to make from the posterior
        seed: A seed or a RandomState object to draw from

    Returns:
        An array of `num_draws` from the posterior
    """
    if isinstance(seed, int):
        seed = np.random.RandomState(seed)

    α_plus_β = st.pareto.rvs(1.5, size=num_draws, random_state=seed)
    proportion = st.uniform.rvs(size=num_draws, random_state=seed)
    α = α_plus_β * proportion
    β = α_plus_β * (1 - proportion)

    post_α = α + num_successes
    post_β = β + num_failures

    return st.beta.rvs(post_α, post_β, random_state=seed)


def draw_all_thetas(
    num_treatments: int,
    treatment_assignments: np.ndarray,
    observed: np.ndarray,
    num_draws: int,
    seed: Optional[Union[int, np.random.mtrand.RandomState]] = None,
) -> np.ndarray:
    """
    Draw from the posterior probability distribution of the probability of
    success for each arm `num_draws` times

    Args:
        num_treatments: the number of arms
        treatment_assignments: the historical data's assignments to each arm
        observed: the outcome of each individual
        num_draws: the number of draws of the posterior
        seed: A seed or a RandomState object to draw from

    Returns:
        A (num_draws x num_treatments) array of posterior probabilities
        of success for each arm
    """
    if isinstance(seed, int):
        seed = np.random.RandomState(seed)

    thetas = []
    for treatment in range(num_treatments):
        these = treatment_assignments == treatment
        num_successes = observed[these].sum()
        num_failures = these.sum() - num_successes

        thetas.append(
            draw_posterior_theta(
                num_successes, num_failures, num_draws, seed=seed
            ).reshape(-1, 1)
        )

    return np.hstack(thetas)


def get_assignments(
    num_treatments: int,
    treatment_assignments: np.ndarray,
    observed: np.ndarray,
    num_draws: int,
    uniform_probability: float,
    seed: Optional[Union[int, np.random.mtrand.RandomState]] = None,
) -> Tuple[List[int], List[bool]]:
    """
    Assign an arm for each of `num_draws` given our ε-bounded Thompson Sampling
    strategy.

    Args:
        num_treatments: the number of arms
        treatment_assignments: the historical data's assignments to each arm
        observed: the outcome of each individual
        num_draws: the number of treatment assginments to make
        uniform_probability: the likelihood that a person is assigned by the
            Thompson sampler or uniformly at random to an arm
        seed: A seed or a RandomState object to draw from

    Returns:
        * the assignment to an arm (0-indexed)
        * whehter the assignment was by the Thompson sampler or the uniform sampler
    """
    if isinstance(seed, int):
        seed = np.random.RandomState(seed)

    thetas = draw_all_thetas(
        num_treatments, treatment_assignments, observed, num_draws, seed=seed
    )

    model_assignment = np.argmax(thetas, axis=1)
    uniform_assignment = np.floor(
        st.uniform.rvs(size=num_draws, random_state=seed) * num_treatments
    ).astype(int)
    which = st.bernoulli.rvs(uniform_probability, size=num_draws, random_state=seed)
    final_assignment = which * uniform_assignment + (1 - which) * model_assignment
    return final_assignment, which
