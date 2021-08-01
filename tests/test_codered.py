import tempfile
from pathlib import Path

import pandas as pd

from thompson import codered


def test_to_excel_row():
    example = codered.CoderedContact(1, "Kevin", "Wilson", "batch_1", "1234567890")
    assert len(example.to_excel_row()) == len(codered.EXCEL_HEADERS)


def test_make_excel_file():
    data = [
        codered.CoderedContact(1, "Kevin", "Wilson", "batch_1", "1234567890"),
        codered.CoderedContact(2, "Ed", "Huh", "batch_2", "1987654321"),
    ]
    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)
        excel_file = tmpdir / "test.xlsx"
        codered.make_excel_file(tmpdir / excel_file, data)
        df = pd.read_excel(excel_file)

    assert tuple(df.columns) == codered.EXCEL_HEADERS
    assert df.iloc[0]["ContactId"] == 1
    assert df.iloc[0]["First Name"] == "Kevin"
    assert df.iloc[0]["Last Name"] == "Wilson"
    assert df.iloc[0]["Groups"] == "batch_1"
    # N.B. It seems like the ExcelWriter converts these strings to ints
    #      Can this be fixed?
    assert df.iloc[0]["TextNumber"] == 1234567890
    assert df.iloc[0]["Preferred Language"] == "English"

    assert df.iloc[1]["ContactId"] == 2
    assert df.iloc[1]["First Name"] == "Ed"
    assert df.iloc[1]["Last Name"] == "Huh"
    assert df.iloc[1]["Groups"] == "batch_2"
    # N.B. It seems like the ExcelWriter converts these strings to ints
    #      Can this be fixed?
    assert df.iloc[1]["TextNumber"] == 1987654321
    assert df.iloc[1]["Preferred Language"] == "English"
