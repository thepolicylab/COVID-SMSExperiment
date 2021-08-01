"""
Types used throughout the project
"""
import io
from contextlib import contextmanager
from pathlib import Path
from typing import ContextManager, Union

FilenameType = Union[str, Path]
FileType = Union[FilenameType, io.IOBase]


@contextmanager
def open_or_yield(filename: FileType, mode: str = "r") -> ContextManager[io.IOBase]:
    """
    Convenience function that either opens a filename in `mode` or simply yields
    the already opened file
    """
    if isinstance(filename, io.IOBase):
        yield filename
    else:
        with open(filename, mode=mode) as ofile:
            yield ofile
