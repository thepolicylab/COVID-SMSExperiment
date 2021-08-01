"""
Functions for working with data from RIDOH
"""

import pandas as pd

from .types import FileType

CSV_HEADERS_TO_DF_HEADERS = {
    "IDL_Phone": "phone_number",
    "test_history": "test_history",
    "age": "age",
    "zip_idl": "zipcode",
    "muni_idl": "municipality",
    "race_eth_final": "race_ethnicity",
    "sex_idl": "sex",
    "SF_Primary_Language__c_case": "preferred_language",
}


CSV_RACE_TO_DF_RACE = {
    "5.White (non-Hispanic or ethnicity unknown or declined)": "white",
    "9.Unknown or pending further information": "unknown",
    "0.Hispanic or Latino (any race)": "hispanic",
    "3.Black or African American (non-Hispanic or ethnicity unknown or declined)": "black",
    "8.Declined race (non-Hispanic or ethnicity unknown or declined)": "declined",
    "6.Other race (non-Hispanic or ethnicity unknown or declined)": "other",
}


def read_unvaccinated_csv(filename: FileType) -> pd.DataFrame:
    """
    Read in a collection of unvaccinated individuals in the format that
    RIDOH provides and make some small data cleaning checks
    """
    df = pd.read_csv(filename)
    df.rename(columns=CSV_HEADERS_TO_DF_HEADERS, inplace=True)

    # TODO(khw): Verify that all phone numbers are 10 digits long
    df["unique_id"] = df["unique_id"].str.strip()

    # TODO(khw): Are there any null races?
    df["race_eth"] = df["race_eth"].str.strip().map(CSV_RACE_TO_DF_RACE)

    df["sex"] = (
        df["sex"]
        .str.strip()
        .str.upper()
        .map(
            {
                "M": "male",
                "F": "female",
                "U": "unknown",
            }
        )
    )

    df["age"] = df["age"].astype(int)
    df["current_age"] = df["current_age"].astype(int)

    df["zcta"] = df["zcta"].apply(lambda x: f"{x:05d}")

    # They seem to have saved with index = True :-/
    return df[
        [
            "unique_id",
            "current_age",
            "age",
            "sex",
            "city",
            "zcta",
            "race_eth",
            "primary_language",
            "test_result",
        ]
    ]
