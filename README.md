# 📊 E-Commerce Analytics Project (Power BI + PostgreSQL)

## 🔍 Business Problem
Online retail businesses generate massive transactional data, but without
structured analytics it is difficult to track sales performance, customer
retention, logistics efficiency, and regional demand.

This project simulates a real-world analytics workflow to transform raw
e-commerce data into actionable business insights.

---

## 📦 Dataset

Due to file size limitations, raw CSV files are not included in this repository.

Dataset Source:
- Kaggle – Brazilian E-Commerce Public Dataset
- Records: ~100K orders
- Files: Orders, Customers, Products, Payments, Reviews, Sellers, Geolocation,Order list

Steps to access data:
1. Download dataset from Kaggle
2. Extract CSV files
3. Load into PostgreSQL or Power BI

---

## 🛠️ Tools & Technologies
- PostgreSQL (data modeling & SQL views)
- Power BI (dashboarding & visualization)
- Power Query (data transformation)
- SQL (CTEs, joins, aggregations)
- GitHub (project documentation)

---

## 🧱 Data Modeling
- Loaded raw CSV files into PostgreSQL
- Created analytical views for dashboards
- Designed a star-schema style model for Power BI
- Handled missing values and delivery date anomalies

---

## 📈 Dashboards & Analysis

### 1️⃣ Executive Overview
**Focus:** Business performance snapshot  
- Revenue, Orders, Customers KPIs
- Monthly trends

### 2️⃣ Sales & Product Performance
**Focus:** Revenue drivers  
- Top products and categories
- Contribution analysis

### 3️⃣ Customer & Retention
**Focus:** Customer behavior  
- New vs repeat customers
- Retention patterns

### 4️⃣ Geographic & Market Analysis
**Focus:** Regional performance  
- State-wise revenue and orders
- Delivery speed vs demand

---

## 🧠 Key Insights
- Revenue is highly concentrated in a few regions
- Repeat customers contribute disproportionately to revenue
- Certain states and sellers drive most delivery delays

---

## 💡 Business Recommendations
- Focus retention strategies on high-value customers
- Expand marketing in fast-delivery, low-revenue regions

---

## ▶️ How to Run the Project
1. Clone this repository
2. Open the `.pbix` file in Power BI Desktop
3. Refresh data connections
4. Explore dashboards using filters and drill-downs

---
