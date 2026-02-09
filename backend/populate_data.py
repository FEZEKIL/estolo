import os
import sqlite3
import pymysql
from datetime import datetime, timedelta
import uuid

def get_db_engine() -> str:
    engine = os.getenv("DB_ENGINE", "").strip().lower()
    if engine:
        return engine
    if os.getenv("DB_HOST"):
        return "mysql"
    return "sqlite"

def get_mysql_config():
    host = os.getenv("DB_HOST")
    name = os.getenv("DB_NAME")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    port = int(os.getenv("DB_PORT", "3306"))

    if not all([host, name, user, password]):
        raise RuntimeError(
            "MySQL configuration missing. Set DB_HOST, DB_NAME, DB_USER, "
            "DB_PASSWORD, and optional DB_PORT."
        )

    return host, name, user, password, port

def get_conn():
    engine = get_db_engine()
    if engine == "mysql":
        host, name, user, password, port = get_mysql_config()
        return pymysql.connect(
            host=host,
            user=user,
            password=password,
            database=name,
            port=port,
            cursorclass=pymysql.cursors.Cursor,
            autocommit=False,
        )
    if engine == "sqlite":
        return sqlite3.connect("estolo.db")
    raise RuntimeError("Unsupported DB_ENGINE. Use 'sqlite' or 'mysql'.")

def get_paramstyle():
    return "qmark" if get_db_engine() == "sqlite" else "format"

def sql_params(sql: str) -> str:
    if get_paramstyle() == "qmark":
        return sql
    return sql.replace("?", "%s")

def populate_sample_data():
    conn = get_conn()
    cursor = conn.cursor()
    
    # Sample products
    products = [
        ('Bread', 25, 12.50, '6001234567890', 'Bakery'),
        ('Milk 1L', 18, 18.90, '6001234567891', 'Dairy'),
        ('Eggs (12 pack)', 12, 25.00, '6001234567892', 'Dairy'),
        ('Sugar 1kg', 30, 15.50, '6001234567893', 'Grocery'),
        ('Cooking Oil 750ml', 8, 32.00, '6001234567894', 'Grocery'),
        ('Rice 2kg', 15, 28.90, '6001234567895', 'Grocery'),
        ('Soap Bar', 45, 8.50, '6001234567896', 'Household'),
        ('Toothpaste', 22, 19.90, '6001234567897', 'Health'),
        ('Chips (Small)', 35, 12.00, '6001234567898', 'Snacks'),
        ('Cold Drink 500ml', 28, 15.00, '6001234567899', 'Beverages')
    ]
    
    # Insert products
    for name, stock, price, barcode, category in products:
        product_id = str(uuid.uuid4())
        created_at = (datetime.now() - timedelta(days=10)).isoformat()
        sql = sql_params('''
            INSERT INTO products (id, name, stock, price, barcode, category, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''')
        cursor.execute(sql, (product_id, name, stock, price, barcode, category, created_at))
    
    # Sample suppliers
    suppliers = [
        ('Fresh Foods Distributors', '0821234567', 'Johannesburg CBD', 'orders@freshfoods.co.za', 'Fresh Foods Distributors'),
        ('Dairy Direct', '0839876543', 'Sandton', 'info@dairydirect.co.za', 'Dairy Direct Suppliers'),
        ('Bakery Supply Co', '0845551234', 'Pretoria', None, 'Bakery Supply Company'),
        ('General Grocers Ltd', '0817778888', 'Centurion', 'sales@grocers.co.za', 'General Grocers Ltd'),
        ('Township Supplies', '0791112233', 'Soweto', None, 'Township Supplies Network')
    ]
    
    # Insert suppliers
    for name, phone, location, email, business_name in suppliers:
        supplier_id = str(uuid.uuid4())
        created_at = (datetime.now() - timedelta(days=30)).isoformat()
        sql = sql_params('''
            INSERT INTO suppliers (id, name, phone, location, email, business_name, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''')
        cursor.execute(sql, (supplier_id, name, phone, location, email, business_name, created_at))
    
    # Sample sales data for the past week
    cursor.execute("SELECT id, name, price FROM products")
    product_data = cursor.fetchall()
    
    if product_data:
        # Generate some sample sales
        import random
        for i in range(15):  # 15 sample sales
            product = random.choice(product_data)
            product_id, product_name, price = product
            quantity = random.randint(1, 5)
            total_price = price * quantity
            sale_date = (datetime.now() - timedelta(days=random.randint(0, 6))).isoformat()
            sale_id = str(uuid.uuid4())
            
            sql = sql_params('''
                INSERT INTO sales (id, product_id, product_name, quantity, price, total_price, date)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''')
            cursor.execute(sql, (sale_id, product_id, product_name, quantity, price, total_price, sale_date))
    
    conn.commit()
    conn.close()
    print("Sample data populated successfully!")

if __name__ == "__main__":
    populate_sample_data()
