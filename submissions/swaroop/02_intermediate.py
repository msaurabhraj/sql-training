from pathlib import Path

import duckdb

con = duckdb.connect("training.duckdb")
con.execute(Path("../../00_setup.sql").read_text())

sql_text = Path("sql/02_intermediate.sql").read_text()

for query in sql_text.split(";"):
  query = query.strip()

  if not query:
    continue

  if "select" not in query.lower():
    continue

  print("\n-- Running query --")
  print(query)
  print()

  con.sql(query).show()
