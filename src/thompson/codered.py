"""
Functions and classes for interacting with the CodeRED data format
"""
from dataclasses import dataclass
from typing import List, Optional, Union

import pandas as pd

from .types import FilenameType

# The required headers for CodeRED
EXCEL_HEADERS = (
    "Command",
    "CustomKey",
    "ContactId",
    "First Name",
    "Last Name",
    "Groups",
    "Tags",
    "HomePhone",
    "WorkPhone",
    "CellPhone",
    "OtherPhone",
    "TextNumber",
    "MobileProvider",
    "HomeEmail",
    "WorkEmail",
    "OtherEmail",
    "StreetAddress",
    "City",
    "State",
    "Zip",
    "Zip4",
    "Preferred Language",
)

# The name of the Worksheet to submit to CodeRED
EXCEL_SHEET_NAME = "5. CodeRed"


@dataclass(frozen=True)
class CoderedContact:
    """A representation of a contact ot be sent to CodeRED"""

    contact_id: Union[str, int]
    first_name: str
    last_name: str

    # Represents the text message the person will get
    groups: str

    # Must be exactly 10 characters
    text_number: str

    # Maybe necessary?
    tags: str = "English"
    preferred_language: str = "English"

    command: Optional[str] = None
    custom_key: Optional[str] = None
    home_phone: Optional[str] = None
    work_phone: Optional[str] = None
    cell_phone: Optional[str] = None
    other_phone: Optional[str] = None
    mobile_provider: Optional[str] = None
    home_email: Optional[str] = None
    work_email: Optional[str] = None
    other_email: Optional[str] = None

    street_address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    zip_code_plus_four: Optional[str] = None

    def to_excel_row(self) -> List[Optional[Union[int, str]]]:
        """
        Convert this contact into a row in the appropriate order for Excel output
        """
        return [
            self.command,
            self.custom_key,
            self.contact_id,
            self.first_name,
            self.last_name,
            self.groups,
            self.tags,
            self.home_phone,
            self.work_phone,
            self.cell_phone,
            self.other_phone,
            self.text_number,
            self.mobile_provider,
            self.home_email,
            self.work_email,
            self.other_email,
            self.street_address,
            self.city,
            self.state,
            self.zip_code,
            self.zip_code_plus_four,
            self.preferred_language,
        ]


def make_df_from_data(contacts: List[CoderedContact]) -> pd.DataFrame:
    """
    Convert a list of contacts to a data frame for easy conversion to Excel

    Args:
        contacts: The contacts to transform into a data frame

    Returns:
        The contacts as a data frame
    """
    data = [contact.to_excel_row() for contact in contacts]
    return pd.DataFrame.from_records(data, columns=EXCEL_HEADERS)


def make_excel_file(
    filename: FilenameType, contacts: List[CoderedContact], drop_message_0: bool = True
):
    """
    Turn a list of contacts into an Excel file stored at `filename`.

    Args:
        filename: The location of the Excel file to create
        contacts: The contacts to transform into an Excel file
        drop_message_0: If True, remove those people assigned to message_0
            (i.e., the control) from the output
    """
    df = make_df_from_data(contacts)
    if drop_message_0:
        df = df[df["Groups"] != "message_0"]

    with pd.ExcelWriter(filename) as writer:
        df.to_excel(writer, index=False, sheet_name=EXCEL_SHEET_NAME)
