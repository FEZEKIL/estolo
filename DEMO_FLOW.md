# Demo Flow Script (Hackathon Ready)

## Goal
Deliver a smooth 5-6 minute demo showing authentication, POS, inventory, suppliers, and demand prediction using live data.

## Setup Checklist
1. Ensure Firebase config is added for the device (Android: `android/app/google-services.json`).
2. Confirm backend is reachable on Huawei ECS and connected to Huawei RDS/GaussDB.
3. Use a real email + password (min 6 chars) to login/register.

## Demo Flow (Suggested Timing)
1. **Login (30s)** Show the clean email login and mention "We chose a reliable email flow for MVP speed."
2. **Dashboard (30s)** Point to today's sales and low-stock indicators and emphasize "mobile-first and simple for spaza owners."
3. **POS (60s)** Create a real sale and say "Sales immediately affect analytics."
4. **Inventory (60s)** Add a product or adjust stock, then explain the color-coded stock levels.
5. **Suppliers (45s)** Add a supplier and show quick reorder value with contact details.
6. **Demand Prediction (60s)** Run prediction and explain "Based on the last 7 days, we recommend stock levels."

## Live Data Highlights
1. **Products**: Add a few staples (Bread, Milk, Chips) during the demo.
2. **Suppliers**: Add at least one supplier to show the directory.
3. **Sales**: Capture 2-3 sales to generate analytics.

## Notes
1. Ensure Huawei ECS and RDS/GaussDB are online before the demo.
2. If analytics shows no data, create 2-3 sales in POS to generate trends.
