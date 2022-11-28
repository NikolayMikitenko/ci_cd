import pytest
import pandas as pd
from src.models.rf import get_df

class TestGetDF(object):
    def test_bad_file_path(self):
        with pytest.raises(FileNotFoundError) as exception_info:
            path = './not_existing_path/not_existing_file.csv'
            get_df(path)
        assert exception_info.match(f'File {path} not found.')

    def test_good_file_path(self):
        assert isinstance(get_df('./app/temp/sample.csv'), pd.DataFrame)