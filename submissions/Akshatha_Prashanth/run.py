from pathlib import Path
import duckdb

con = duckdb.connect("training.duckdb")
con.execute(Path("../../00_setup.sql").read_text())

# run your query
con.sql(Path("01_beginner.sql").read_text()).show()