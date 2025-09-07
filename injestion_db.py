from sqlalchemy import create_engine
import pandas as pd
import logging 
import time
import os
engine = create_engine(
    "mssql+pyodbc://MSI\\SQLEXPRESS/project?driver=ODBC+Driver+18+for+SQL+Server&trusted_connection=yes&TrustServerCertificate=yes"
)
print("successfull") 
logging.basicConfig(
    filename='db_ingestion.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def ingest_db(df, table_name, engine):
    df.to_sql(table_name, con=engine, if_exists='replace', index=False)
    logging.info(f"Ingested table: {table_name} ({df.shape[0]} rows, {df.shape[1]} columns)")
def load_raw_data(folder_path):
    start = time.time()
    
    for file in os.listdir(folder_path):
        if file.endswith('.csv'):
            file_path = os.path.join(folder_path, file)
            df = pd.read_csv(file_path)
            logging.info(f"Loading file: {file}")
            table_name = file[:-4]  # Remove '.csv' extension
            print(df.shape)
            ingest_db(df, table_name, engine)
    
    end = time.time()
    logging.info(f"Data ingestion complete in {(end - start)/60:.2f} minutes")
load_raw_data(r'C:\temp')