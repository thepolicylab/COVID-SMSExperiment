from pathlib import Path

from thompson import unvaccinated


def test_read_unvaccinated_csv(fixtures_path: Path):
    # For now just make sure that everything can be read and there's no obvious errors
    unvaccinated.read_unvaccinated_csv(fixtures_path / "sample_unvaccinated_file.csv")
