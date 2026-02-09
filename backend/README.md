# Estolo Backend API

Smart Spaza Shop Management System - FastAPI Backend

## Overview

Estolo Backend is a REST API for managing inventory, sales, suppliers, and analytics for small retail shops (spaza shops). Built with FastAPI and supports both SQLite (development) and MySQL (production).

## Features

- ✅ Product Management (CRUD)
- ✅ Inventory Tracking
- ✅ Sales Recording & History
- ✅ Supplier Management
- ✅ Product Categories (Fruits, Vegetables, Grains, etc.)
- ✅ Demand Prediction Analytics
- ✅ Database Abstraction (SQLite/MySQL)
- ✅ CORS Support for frontend integration
- ✅ Health Check Endpoints

## Quick Start

### Prerequisites

- Python 3.8+
- pip or conda
- SQLite (included with Python) or MySQL server

### Setup

1. **Clone the repository:**
   ```bash
   cd backend
   ```

2. **Create virtual environment (recommended):**
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment:**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your database settings (see Configuration section).

5. **Run the server:**
   ```bash
   $env:DB_ENGINE="sqlite"  # Windows PowerShell
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

   Or on macOS/Linux:
   ```bash
   export DB_ENGINE=sqlite
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

6. **Access the API:**
   - API: http://localhost:8000
   - API Docs (Swagger): http://localhost:8000/docs
   - Alternative Docs (ReDoc): http://localhost:8000/redoc

## Configuration

### Environment Variables

Create a `.env` file (see `.env.example`) with:

#### SQLite (Development - Default)
```env
DB_ENGINE=sqlite
```

#### MySQL (Production)
```env
DB_ENGINE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_NAME=estolo
DB_USER=estolo_user
DB_PASSWORD=your_secure_password
```

### Database Initialization

The database is automatically initialized on server startup. Tables created:
- `products` — Inventory items with pricing & stock
- `sales` — Transaction records with timestamps
- `suppliers` — Supplier contact information
- `categories` — Product categories (pre-seeded with 27 categories)

## API Endpoints

### Health & Status

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API root info |
| GET | `/health` | Health check |
| GET | `/health/db` | Database health check |

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | List all products |
| POST | `/api/products` | Create product (auto-creates category if needed) |
| PUT | `/api/products/{id}` | Update product |
| DELETE | `/api/products/{id}` | Delete product |

### Sales

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/sales` | List all sales (ordered by date DESC) |
| POST | `/api/sales` | Record sale (auto-updates stock) |
| PUT | `/api/sales/{id}` | Update sale (prevents product_id change) |
| DELETE | `/api/sales/{id}` | Delete sale (restores stock) |

### Suppliers

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/suppliers` | List all suppliers |
| POST | `/api/suppliers` | Create supplier |
| PUT | `/api/suppliers/{id}` | Update supplier |
| DELETE | `/api/suppliers/{id}` | Delete supplier |

### Categories

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | List all categories |
| POST | `/api/categories` | Create category (prevents duplicates) |
| DELETE | `/api/categories/{id}` | Delete category (clears product references) |

**Pre-seeded Categories:**
Fruits, Vegetables, Grains, Cereals, Bread & Bakery, Dairy & Eggs, Meat, Poultry, Seafood, Beverages, Juices, Water, Soft Drinks, Alcohol, Snacks, Confectionery, Chocolates, Nuts & Seeds, Oils & Fats, Condiments & Sauces, Spices & Herbs, Canned & Preserved, Frozen Foods, Pasta & Noodles, Rice & Legumes, Baby Food, Health & Specialty

### Analytics

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/analytics/demand` | 7-day demand prediction & recommendations |

## Example Requests

### Create a Product

```bash
curl -X POST http://localhost:8000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "id": "prod-001",
    "name": "Apples",
    "stock": 50,
    "price": 2.50,
    "barcode": "123456789",
    "category": "fruits",
    "created_at": "2026-02-09T10:30:00"
  }'
```

### Record a Sale

```bash
curl -X POST http://localhost:8000/api/sales \
  -H "Content-Type: application/json" \
  -d '{
    "id": "sale-001",
    "product_id": "prod-001",
    "product_name": "Apples",
    "quantity": 5,
    "price": 2.50,
    "total_price": 12.50,
    "date": "2026-02-09T10:35:00"
  }'
```

### Get Demand Prediction

```bash
curl http://localhost:8000/api/analytics/demand
```

Response:
```json
{
  "recommended_stock": 25,
  "confidence": "high",
  "average_daily_sales": 5.0,
  "prediction_period": 5,
  "generated_at": "2026-02-09T10:40:00"
}
```

## Development

### Project Structure

```
backend/
├── main.py              # FastAPI app, routes, models
├── requirements.txt     # Python dependencies
├── .env.example         # Environment template
├── populate_data.py     # Utility to seed demo data
├── estolo.db           # SQLite database (auto-created)
└── README.md           # This file
```

### Running with Auto-reload

```bash
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The `--reload` flag watches for file changes and restarts the server.

### Populate Demo Data

```bash
python populate_data.py
```

Creates sample products, sales, and suppliers for testing.

### Testing Endpoints

Use the interactive Swagger UI at http://localhost:8000/docs to:
- Test all endpoints
- View request/response schemas
- Try different parameters

## Database Notes

### SQLite (Development)
- File-based: `estolo.db` in working directory
- Automatic initialization on startup
- No external setup required
- `?` parameter placeholders

### MySQL (Production)
- Requires `pymysql` dependency (included in requirements.txt)
- Modern cloud databases supported (TaurusDB, Amazon RDS, Google Cloud SQL)
- `%s` parameter placeholders
- Connection pooling recommended for high load

## Security

**Never commit these files:**
- `.env` (contains credentials)
- `google-services.json`
- `agconnect-services.json`

See [../SECURITY.md](../SECURITY.md) for detailed security setup.

## Troubleshooting

### `ModuleNotFoundError: No module named 'pymysql'`
Install dependencies:
```bash
pip install -r requirements.txt
```

### Database connection fails
- Check `.env` file has correct credentials
- Verify MySQL server is running (if using MySQL)
- Ensure database exists before connecting

### Port 8000 already in use
```bash
# Use different port
python -m uvicorn main:app --host 0.0.0.0 --port 8001
```

## Performance Tips

- Enable MySQL connection pooling for production
- Use indexes on frequently queried columns (`product_id`, `category`)
- Paginate large result sets (future enhancement)
- Cache category list (rarely changes)

## Future Enhancements

- [ ] Pagination for large datasets
- [ ] Authentication & authorization (JWT)
- [ ] Batch imports/exports
- [ ] Advanced analytics (trends, forecasting)
- [ ] Webhook notifications
- [ ] API rate limiting
- [ ] Database migrations (Alembic)

## License

Part of the Estolo Smart Spaza Shop Management System

## Support

For issues or questions, refer to the main [README.md](../README.md) or [SECURITY.md](../SECURITY.md)
