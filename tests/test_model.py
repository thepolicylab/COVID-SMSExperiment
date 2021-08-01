import numpy as np
import pandas as pd

from thompson import model


def test_does_it_run():
    df = pd.DataFrame(
        {
            "treatment": [0, 0, 0, 0, 1, 1, 1, 1],
            "outcome": [1, 1, 0, 0, 0, 1, 1, 1],
        }
    )

    first_assignments = model.get_assignments(
        2,
        df["treatment"].values,
        df["outcome"].values,
        20,
        0.25,
        seed=np.random.RandomState(239102),
    )
    assert first_assignments.shape == (20,)

    # Make sure seed setting works; this time just passing the bare seed
    second_assignments = model.get_assignments(
        2,
        df["treatment"].values,
        df["outcome"].values,
        20,
        0.25,
        seed=239102,
    )

    assert (first_assignments == second_assignments).all()
