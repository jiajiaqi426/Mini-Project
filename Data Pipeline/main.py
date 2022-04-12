# Ticket System Project

# Import packages
import os
import pandas as pd
import mysql.connector
import logging


# Set up database connection:
def get_db_connection():
    connection = None
    try:
        connection = mysql.connector.connect(user="root",
                                             password="123456",
                                             host="localhost",
                                             port="3306",
                                             database="ticket_system")
    except Exception as error:
        logging.error("Error while connecting to database for job tracker", error)
    return connection


# Load CSV to table:
def load_third_party(connection, file_path_csv):
    try:
        #  Use the Python connector to insert each record of the CSV file into the “sales” table.
        #  Create cursor object
        cursor = connection.cursor()
        # {Iterate through CSV file and execute insert statement}
        ticket_data = pd.read_csv(file_path_csv, header=None)
        # Create tickets table to store data
        sql_ddl_statement = """

        DROP DATABASE IF EXISTS ticket_system;
        CREATE DATABASE ticket_system;
        USE ticket_system;

        CREATE TABLE ticket_sales_table(
            ticket_id INT,
            trans_date DATE,
            event_id INT,
            event_name VARCHAR(50),
            event_date DATE,
            event_type VARCHAR(10),
            event_city VARCHAR(20),
            customer_id INT,
            price DECIMAL(7,2),
            num_tickets INT,
            PRIMARY KEY(ticket_id)
            );
        """

        for _ in cursor.execute(sql_ddl_statement, multi=True):
            pass
            print('execute sql_ddl_statement')

        for i, row in ticket_data.iterrows():
            # iterate over DataFrame rows as (index, Series) pairs
            sql = """INSERT INTO ticket_system.ticket_sales_table
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);"""
            cursor.execute(sql, tuple(row))
        connection.commit()
        cursor.close()
    except Exception as exception:
        #  Closes the cursor, resets all results, cursor object has no reference to original connection object
        cursor.close()
        logging.error("There are errors when connecting to MYSQL", exception)


# Display statistical information:
def query_popular_tickets(connection):
    # Get the most popular ticket in the past month
    sql_statement = """
    select event_name, Total_Tickets
    FROM(SELECT event_name,SUM(num_tickets) 'Total_Tickets', rank() over( order by SUM(num_tickets) desc) AS tickets_rank 
    FROM ticket_system.ticket_sales_table
    group by event_name)a where a.tickets_rank = 1
    """
    cursor = connection.cursor()
    cursor.execute(sql_statement)
    # fetches all (or all remaining) rows of a query result set and returns a list of tuples.
    records = cursor.fetchall()
    cursor.close()
    return records


if __name__ == "__main__":
    # Connect to MySQL database
    connect = get_db_connection()

    # Load CSV data to Mysql database, returns current working directory of a process
    current_wd = os.getcwd()
    csv_file_path = current_wd + '/third_party_sales_1.csv'
    load_third_party(connect, csv_file_path)

    # Execute SQL query
    print(query_popular_tickets(connect))