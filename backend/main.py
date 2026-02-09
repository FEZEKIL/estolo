from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
import sqlite3
try:
    import pymysql
except Exception:
    pymysql = None
from datetime import datetime
import uvicorn

app = FastAPI(title="Estolo Backend API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database setup
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
        if pymysql is None:
            raise RuntimeError(
                "pymysql is not installed. Install it with: pip install pymysql"
            )
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

def init_db():
    conn = get_conn()
    cursor = conn.cursor()
    datetime_type = "TEXT" if get_db_engine() == "sqlite" else "DATETIME"
    
    # Create tables
    cursor.execute(f'''
        CREATE TABLE IF NOT EXISTS products (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            stock INTEGER NOT NULL,
            price REAL NOT NULL,
            barcode TEXT,
            category TEXT,
            created_at {datetime_type} NOT NULL
        )
    ''')
    
    cursor.execute(f'''
        CREATE TABLE IF NOT EXISTS sales (
            id TEXT PRIMARY KEY,
            product_id TEXT NOT NULL,
            product_name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            total_price REAL NOT NULL,
            date {datetime_type} NOT NULL
        )
    ''')
    
    cursor.execute(f'''
        CREATE TABLE IF NOT EXISTS suppliers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            location TEXT NOT NULL,
            email TEXT,
            business_name TEXT,
            created_at {datetime_type} NOT NULL
        )
    ''')

    cursor.execute(f'''
        CREATE TABLE IF NOT EXISTS categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            created_at {datetime_type} NOT NULL
        )
    ''')

    # Seed comprehensive Foods & Drinks categories
    default_categories = [
        "fruits",
        "vegetables",
        "grains",
        "cereals",
        "bread_and_bakery",
        "dairy_and_eggs",
        "meat",
        "poultry",
        "seafood",
        "beverages",
        "juices",
        "water",
        "soft_drinks",
        "alcohol",
        "snacks",
        "confectionery",
        "chocolates",
        "nuts_and_seeds",
        "oils_and_fats",
        "condiments_and_sauces",
        "spices_and_herbs",
        "canned_and_preserved",
        "frozen_foods",
        "pasta_and_noodles",
        "rice_and_legumes",
        "baby_food",
        "health_and_specialty",
    ]
    for cat_name in default_categories:
        sql_check = sql_params('SELECT id FROM categories WHERE name = ?')
        cursor.execute(sql_check, (cat_name,))
        if not cursor.fetchone():
            created_at = datetime.now().isoformat()
            sql_ins = sql_params('INSERT INTO categories (id, name, created_at) VALUES (?, ?, ?)')
            cursor.execute(sql_ins, (cat_name, cat_name, created_at))
    
    conn.commit()
    conn.close()

# Pydantic models
class Product(BaseModel):
    id: str
    name: str
    stock: int
    price: float
    barcode: Optional[str] = None
    category: Optional[str] = None
    created_at: str

class Sale(BaseModel):
    id: str
    product_id: str
    product_name: str
    quantity: int
    price: float
    total_price: float
    date: str

class Supplier(BaseModel):
    id: str
    name: str
    phone: str
    location: str
    email: Optional[str] = None
    business_name: Optional[str] = None
    created_at: str

class Category(BaseModel):
    id: str
    name: str
    created_at: str

# Routes
@app.get("/")
async def root():
    return {"message": "Estolo Backend API - Smart Spaza Assistant"}

@app.get("/health")
async def health():
    return {
        "status": "ok",
        "db_engine": get_db_engine(),
    }

@app.get("/health/db")
async def health_db():
    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        conn.close()
        return {
            "status": "ok",
            "db_engine": get_db_engine(),
        }
    except Exception as exc:
        return {
            "status": "error",
            "db_engine": get_db_engine(),
            "error": str(exc),
        }

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/api/products")
async def get_products():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM products ORDER BY name")
    rows = cursor.fetchall()
    conn.close()
    
    products = []
    for row in rows:
        products.append({
            "id": row[0],
            "name": row[1],
            "stock": row[2],
            "price": row[3],
            "barcode": row[4],
            "category": row[5],
            "created_at": row[6]
        })
    
    return products

@app.post("/api/products")
async def create_product(product: Product):
    conn = get_conn()
    cursor = conn.cursor()
    # Ensure category exists in categories table (if provided)
    if product.category:
        sql_check = sql_params('SELECT id FROM categories WHERE name = ?')
        cursor.execute(sql_check, (product.category,))
        existing_cat = cursor.fetchone()
        if not existing_cat:
            sql_cat = sql_params('INSERT INTO categories (id, name, created_at) VALUES (?, ?, ?)')
            cursor.execute(sql_cat, (
                product.category,  # using category name as id for simplicity
                product.category,
                product.created_at,
            ))

    sql = sql_params('''
        INSERT INTO products (id, name, stock, price, barcode, category, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''')
    cursor.execute(sql, (
        product.id,
        product.name,
        product.stock,
        product.price,
        product.barcode,
        product.category,
        product.created_at,
    ))
    conn.commit()
    conn.close()
    return product

@app.put("/api/products/{product_id}")
async def update_product(product_id: str, product: Product):
    conn = get_conn()
    cursor = conn.cursor()
    sql = sql_params('''
        UPDATE products
        SET name = ?,
            stock = ?,
            price = ?,
            barcode = ?,
            category = ?,
            created_at = ?
        WHERE id = ?
    ''')
    cursor.execute(
        sql,
        (
            product.name,
            product.stock,
            product.price,
            product.barcode,
            product.category,
            product.created_at,
            product_id,
        ),
    )
    conn.commit()
    updated = cursor.rowcount
    conn.close()

    if updated == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@app.delete("/api/products/{product_id}")
async def delete_product(product_id: str):
    conn = get_conn()
    cursor = conn.cursor()
    sql = sql_params('DELETE FROM products WHERE id = ?')
    cursor.execute(sql, (product_id,))
    conn.commit()
    deleted = cursor.rowcount
    conn.close()

    if deleted == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"status": "deleted"}


@app.get("/api/categories")
async def get_categories():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, created_at FROM categories ORDER BY name")
    rows = cursor.fetchall()
    conn.close()

    cats = []
    for row in rows:
        cats.append({
            "id": row[0],
            "name": row[1],
            "created_at": row[2],
        })
    return cats


@app.post("/api/categories")
async def create_category(category: Category):
    conn = get_conn()
    cursor = conn.cursor()
    # Prevent duplicate category names
    sql_check = sql_params('SELECT id FROM categories WHERE name = ?')
    cursor.execute(sql_check, (category.name,))
    if cursor.fetchone():
        conn.close()
        raise HTTPException(status_code=400, detail="Category with this name already exists")

    sql = sql_params('INSERT INTO categories (id, name, created_at) VALUES (?, ?, ?)')
    cursor.execute(sql, (category.id, category.name, category.created_at))
    conn.commit()
    conn.close()
    return category


@app.delete("/api/categories/{category_id}")
async def delete_category(category_id: str):
    conn = get_conn()
    cursor = conn.cursor()
    # Remove category reference from products before deleting (set to NULL)
    sql = sql_params('UPDATE products SET category = NULL WHERE category = ?')
    cursor.execute(sql, (category_id,))
    sql = sql_params('DELETE FROM categories WHERE id = ?')
    cursor.execute(sql, (category_id,))
    conn.commit()
    deleted = cursor.rowcount
    conn.close()

    if deleted == 0:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"status": "deleted"}

@app.get("/api/sales")
async def get_sales():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM sales ORDER BY date DESC")
    rows = cursor.fetchall()
    conn.close()
    
    sales = []
    for row in rows:
        sales.append({
            "id": row[0],
            "product_id": row[1],
            "product_name": row[2],
            "quantity": row[3],
            "price": row[4],
            "total_price": row[5],
            "date": row[6]
        })
    
    return sales

@app.post("/api/sales")
async def create_sale(sale: Sale):
    conn = get_conn()
    cursor = conn.cursor()
    
    # Insert sale
    sql = sql_params('''
        INSERT INTO sales (id, product_id, product_name, quantity, price, total_price, date)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''')
    cursor.execute(sql, (
        sale.id,
        sale.product_id,
        sale.product_name,
        sale.quantity,
        sale.price,
        sale.total_price,
        sale.date
    ))
    
    # Update product stock
    sql = sql_params('''
        UPDATE products 
        SET stock = stock - ? 
        WHERE id = ?
    ''')
    cursor.execute(sql, (sale.quantity, sale.product_id))
    
    conn.commit()
    conn.close()
    return sale

@app.put("/api/sales/{sale_id}")
async def update_sale(sale_id: str, sale: Sale):
    conn = get_conn()
    cursor = conn.cursor()

    sql = sql_params('SELECT id, product_id, quantity FROM sales WHERE id = ?')
    cursor.execute(sql, (sale_id,))
    existing = cursor.fetchone()
    if not existing:
        conn.close()
        raise HTTPException(status_code=404, detail="Sale not found")

    existing_product_id = existing[1]
    existing_quantity = existing[2]

    if existing_product_id != sale.product_id:
        conn.close()
        raise HTTPException(
            status_code=400,
            detail="Changing product_id for a sale is not supported",
        )

    quantity_delta = sale.quantity - existing_quantity
    if quantity_delta != 0:
        sql = sql_params('SELECT stock FROM products WHERE id = ?')
        cursor.execute(sql, (sale.product_id,))
        product = cursor.fetchone()
        if not product:
            conn.close()
            raise HTTPException(status_code=404, detail="Product not found")
        current_stock = product[0]
        if quantity_delta > 0 and current_stock < quantity_delta:
            conn.close()
            raise HTTPException(
                status_code=400,
                detail="Insufficient stock for updated sale quantity",
            )

        sql = sql_params('''
            UPDATE products
            SET stock = stock - ?
            WHERE id = ?
        ''')
        cursor.execute(sql, (quantity_delta, sale.product_id))

    sql = sql_params('''
        UPDATE sales
        SET product_name = ?,
            quantity = ?,
            price = ?,
            total_price = ?,
            date = ?
        WHERE id = ?
    ''')
    cursor.execute(
        sql,
        (
            sale.product_name,
            sale.quantity,
            sale.price,
            sale.total_price,
            sale.date,
            sale_id,
        ),
    )

    conn.commit()
    conn.close()
    return sale

@app.delete("/api/sales/{sale_id}")
async def delete_sale(sale_id: str):
    conn = get_conn()
    cursor = conn.cursor()

    sql = sql_params('SELECT id, product_id, quantity FROM sales WHERE id = ?')
    cursor.execute(sql, (sale_id,))
    existing = cursor.fetchone()
    if not existing:
        conn.close()
        raise HTTPException(status_code=404, detail="Sale not found")

    product_id = existing[1]
    quantity = existing[2]

    sql = sql_params('DELETE FROM sales WHERE id = ?')
    cursor.execute(sql, (sale_id,))

    sql = sql_params('''
        UPDATE products
        SET stock = stock + ?
        WHERE id = ?
    ''')
    cursor.execute(sql, (quantity, product_id))

    conn.commit()
    conn.close()
    return {"status": "deleted"}

@app.get("/api/suppliers")
async def get_suppliers():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM suppliers ORDER BY name")
    rows = cursor.fetchall()
    conn.close()
    
    suppliers = []
    for row in rows:
        suppliers.append({
            "id": row[0],
            "name": row[1],
            "phone": row[2],
            "location": row[3],
            "email": row[4],
            "business_name": row[5],
            "created_at": row[6]
        })
    
    return suppliers

@app.post("/api/suppliers")
async def create_supplier(supplier: Supplier):
    conn = get_conn()
    cursor = conn.cursor()
    sql = sql_params('''
        INSERT INTO suppliers (id, name, phone, location, email, business_name, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''')
    cursor.execute(sql, (
        supplier.id,
        supplier.name,
        supplier.phone,
        supplier.location,
        supplier.email,
        supplier.business_name,
        supplier.created_at
    ))
    conn.commit()
    conn.close()
    return supplier

@app.put("/api/suppliers/{supplier_id}")
async def update_supplier(supplier_id: str, supplier: Supplier):
    conn = get_conn()
    cursor = conn.cursor()
    sql = sql_params('''
        UPDATE suppliers
        SET name = ?,
            phone = ?,
            location = ?,
            email = ?,
            business_name = ?,
            created_at = ?
        WHERE id = ?
    ''')
    cursor.execute(
        sql,
        (
            supplier.name,
            supplier.phone,
            supplier.location,
            supplier.email,
            supplier.business_name,
            supplier.created_at,
            supplier_id,
        ),
    )
    conn.commit()
    updated = cursor.rowcount
    conn.close()

    if updated == 0:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return supplier

@app.delete("/api/suppliers/{supplier_id}")
async def delete_supplier(supplier_id: str):
    conn = get_conn()
    cursor = conn.cursor()
    sql = sql_params('DELETE FROM suppliers WHERE id = ?')
    cursor.execute(sql, (supplier_id,))
    conn.commit()
    deleted = cursor.rowcount
    conn.close()

    if deleted == 0:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return {"status": "deleted"}

@app.get("/api/analytics/demand")
async def get_demand_prediction():
    conn = get_conn()
    cursor = conn.cursor()
    
    # Get sales from last 7 days
    if get_db_engine() == "mysql":
        sales_sql = '''
            SELECT product_id,
                   SUM(quantity) as total_quantity,
                   COUNT(DISTINCT DATE(date)) as days_with_sales
            FROM sales 
            WHERE date >= NOW() - INTERVAL 7 DAY
            GROUP BY product_id
        '''
    else:
        sales_sql = '''
            SELECT product_id,
                   SUM(quantity) as total_quantity,
                   COUNT(DISTINCT DATE(date)) as days_with_sales
            FROM sales 
            WHERE date >= DATE('now', '-7 days')
            GROUP BY product_id
        '''
    cursor.execute(sales_sql)
    
    rows = cursor.fetchall()
    conn.close()
    
    if not rows:
        return {
            "recommended_stock": 0,
            "confidence": "low",
            "average_daily_sales": 0,
            "prediction_period": 5,
            "generated_at": datetime.now().isoformat()
        }
    
    # Simple demand prediction logic
    total_quantity = sum(row[1] for row in rows)
    total_days = sum(row[2] for row in rows)
    average_daily_sales = total_quantity / max(total_days, 1)
    recommended_stock = round(average_daily_sales * 5)
    
    # Determine confidence
    confidence = "high" if total_days >= 5 else "medium" if total_days >= 3 else "low"
    
    return {
        "recommended_stock": recommended_stock,
        "confidence": confidence,
        "average_daily_sales": average_daily_sales,
        "prediction_period": 5,
        "generated_at": datetime.now().isoformat()
    }

if __name__ == "__main__":
    init_db()
    uvicorn.run(app, host="0.0.0.0", port=8000)
