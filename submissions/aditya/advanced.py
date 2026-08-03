from pathlib import Path
import duckdb

# Resolve paths relative to this script so the script runs from any CWD
HERE = Path(__file__).parent
REPO_ROOT = HERE.parent.parent
SETUP_SQL = REPO_ROOT / "00_setup.sql"
SQL_FILE = HERE / "sql" / "advanced_sol.sql"

con = duckdb.connect(str(HERE / "training.duckdb"))
con.execute(SETUP_SQL.read_text())

sql_text = SQL_FILE.read_text()

queries = [q.strip() for q in sql_text.split(";") if q.strip()]

for i, query in enumerate(queries, start=1):
  print("\n" + "=" * 60)
  print(f"que{i}")
  print("=" * 60)

  # print the SQL source for this question
  print("\nSolution:\n")
  print(query.strip() + ";")

  # execute and show results
  print("\nOutput:\n")
  con.sql(query).show()
  print("\n" + "-" * 60)
