# 📚 Relational Database Design & Data Modeling Project

## Overview
This project demonstrates the end-to-end design and implementation of a **library management database**,
covering the full lifecycle from conceptual modeling to analytical data modeling.

The main objective is to show how transactional data can be:
- designed using proper **relational modeling principles**, and
- transformed into a **dimensional model (star schema)** for analytical use cases.

> This repository focuses on database design decisions and data modeling techniques rather than application development.

---

## Scope & Features
- Conceptual data modeling using **Chen notation**
- Logical data modeling using **Crow’s Foot notation**
- Normalized relational database (OLTP)
- Dimensional modeling for analytics (Star Schema)
- SQL implementation: DDL, DML, and ETL scripts

---

## Data Modeling Process

### 1. Conceptual Model (Chen Notation)
At the conceptual level, entities and relationships were identified based on the business domain
of a library management system.

Main entities include:
- Book, BookCopy
- User, Librarian
- Loan
- Category

This model focuses on **business meaning** and is independent of implementation details.

📌 Diagrams available in `/docs/Chen_ER1.png`

---

### 2. Logical Model (Crow’s Foot Notation)
The conceptual model was refined into a logical schema using Crow’s Foot notation.

Key design decisions:
- Resolution of many-to-many relationships using junction tables
- Hierarchical categories modeled with self-referencing keys
- Multi-valued attributes (phone numbers, addresses) separated into dependent tables

📌 Diagrams available in `/docs/Crows_Foot1.png`

---

### 3. Physical Relational Model (OLTP)
The logical model was translated into a physical relational schema implemented using SQL.

Key characteristics:
- Normalized up to **Third Normal Form (3NF)**
- Primary key and foreign key constraints
- Clear separation of entities (User, Book, Loan, etc.)
- Audit columns for tracking data changes (`CreatedOn`, `ModifiedOn`)

📌 SQL scripts:
- `/sql/normalization/ddl.sql` – table definitions and constraints
- `/sql/normalization/dml.sql` – sample data population

---

### 4. Dimensional Model (Data Warehouse)
To support analytical queries, the normalized OLTP data was transformed into a **star schema**.

#### Fact Table
- **Fact_Loan**
  - Measures: `ReturnOnTime`
  - Foreign keys to all dimension tables

#### Dimension Tables
- Dim_User
- Dim_Book
- Dim_Librarian
- Dim_Date
- Dim_Geographic

This model enables efficient analysis such as:
- loan trends over time
- user borrowing behavior
- librarian workload analysis

📌 Star schema diagrams available in `/docs/Crows_Foot2.png`

---

## ETL & Data Transformation
An ETL process was implemented to:
- extract data from the normalized OLTP schema
- generate surrogate keys for dimension tables
- populate the fact table with timestamp-based tracking

📌 ETL logic: `/sql/etl/Timestamp_ETL.sql`

---

## Technologies Used
- SQL (DDL, DML, ETL)
- Relational database design principles
- Dimensional modeling (Star Schema)
- ER modeling (Chen & Crow’s Foot)

---

## How to Run
1. Execute DDL scripts to create database tables
2. Run DML scripts to insert sample data
3. Execute ETL scripts to populate dimensional tables
4. Run analytical queries on the star schema

---

## Key Learning Outcomes
- Translating business requirements into conceptual data models
- Applying normalization to ensure data integrity
- Understanding trade-offs between normalized and denormalized designs
- Designing analytical schemas optimized for reporting
- Writing structured and maintainable SQL code

---

## Project Context
This project was completed as part of a university database course and extended to serve as a
**portfolio-ready demonstration of database design and data modeling skills**.
