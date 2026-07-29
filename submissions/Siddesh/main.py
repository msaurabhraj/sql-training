import duckdb

# Connect to database
con = duckdb.connect("training.duckdb")
# Open setup file and execute it
with open("../../00_setup.sql", "r") as file:
    setup_sql = file.read()
con.execute(setup_sql)
# Open query file and run it
with open("01_beginner.sql", "r") as file:
    queries = file.read().split(";")
for query in queries:
    query = query.strip()
    if query:
        print(query)
        con.sql(query).show()

# Close connection
con.close()