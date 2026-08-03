from pathlib import Path
import duckdb

con = duckdb.connect("training.duckdb")
con.execute(Path("../../00_setup.sql").read_text())
queries = Path("sql/03_advanced_solutions.sql").read_text()
for query in queries.split(";"):
  query = query.strip()
  if query:
    print("\n==================================================")
    print(query)
    try:
      con.sql(query).show()
    except Exception as e:  # noqa: BLE001
      print("Error", e)
