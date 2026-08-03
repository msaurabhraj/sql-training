from pathlib import Path
import duckdb

con = duckdb.connect("training.duckdb")
con.execute(Path("../../00_setup.sql").read_text())
queries = Path("sql/01_beginner_solutions.sql").read_text()
for query in queries.split(";"):
  query = query.strip()
  if query:
    print("\n==================================================")
    print(query)
    try:
      con.sql(query).show()
    except Exception as e:
      print("Error", e)
# --load employee list
# con.sql(Path("sql/employee_list.sql").read_text()).show()
