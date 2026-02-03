# 🏛️ Los Abuelos Advisor - Enterprise Data Platform

> **A scalable social platform for business reviews, built on Oracle Database with Advanced PL/SQL automation.**

<p align="center">
  <img src="https://github.com/user-attachments/assets/f08cd207-0965-4e00-a0d1-f3a07694315f" width="45%" alt="Admin Dashboard" />
  &nbsp; &nbsp;
  <img src="https://github.com/user-attachments/assets/1c04a3d0-75b4-4250-b3c9-5321c20e9821" width="45%" alt="Activity Details" />
</p>

## 📋 Project Overview
**Los Abuelos Advisor** is a full-stack data platform designed to simulate a real-world review system (similar to Yelp or TripAdvisor). The project focuses on the **backend architecture**, ensuring data integrity, concurrency control, and high performance through database-level programming.

The system handles complex interactions between Users, Businesses, Reviews, and Check-ins, all managed through a robust **Oracle Database** and visualized via an **Oracle APEX** frontend.

## 🛠️ Tech Stack

<div align="left">
  <img src="https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white" />
  <img src="https://img.shields.io/badge/PL%2FSQL-F80000?style=for-the-badge&logo=oracle&logoColor=white" />
  <img src="https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/Oracle_APEX-F80000?style=for-the-badge&logo=oracle&logoColor=white" />
</div>

## ⚙️ Key Engineering Features

### 1. Advanced PL/SQL Automation
The database manages its own consistency using triggers, moving logic away from the application layer:
- **Real-time Statistics:** Triggers automatically recalculate `Average Rating` and `Review Count` whenever a review is added, updated, or deleted.
- **Concurrency Control:** Implemented `SELECT ... FOR UPDATE` logic inside triggers to prevent *Lost Update* anomalies during simultaneous reviews.
- **Data Validation:** Triggers enforce business rules (e.g., preventing check-ins with future dates) directly at the database level.

### 2. Data Engineering & ETL Pipeline
To simulate a production environment, I implemented an ETL (Extract, Transform, Load) process using the **Yelp Open Dataset**:
- **Source:** Raw data extracted from Yelp (English dataset).
- **Transformation:** Python scripts map the raw data into standardized JSON artifacts (`users.json`, `business.json`, `reviews.json`, `checkin.json`, `tips.json`).
- **Loading:** Automated generation of SQL `INSERT` statements to populate the Italian database schema while maintaining referential integrity.

### 3. Security & Access Control (RBAC)
Implemented a granular security model using Oracle Roles:
- **Admin:** Full access + specialized Analytics Dashboard.
- **Moderator:** Can delete/update content but cannot modify core business data.
- **User:** Restricted access limited to their own content (Reviews, Photos, Friendships).

### 4. Performance Optimization
- **Indexing:** Strategic B-Tree indices on high-cardinality columns (`City`, `Date`, `Category`) to optimize query plans.
- **Referential Integrity:** Extensive use of `ON DELETE CASCADE` to maintain database cleanliness.

## 🗂️ Database Schema
The database models a complex relational system including M:N relationships (Categories, Friendships) and CLOB data types for media descriptions.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9e8c023b-9ca7-4eb9-8e5c-21cea9deaaae" width="85%" alt="ER Diagram" />
</p>

## 📂 Repository Structure
- `sql/`: DDL scripts (`01_Schema.sql`) and PL/SQL logic (`02_Triggers_Procedures.sql`).
- `scripts/`: Python ETL scripts and JSON datasets (`users.json`, `business.json`, etc.).
- `docs/`: Full project documentation (PDF).

## 👥 Authors
- **Giuseppe Allocca** - *Database Design & PL/SQL Implementation*
- Stefano Acri
- Giuseppe Di Donna

---
*Developed as a Capstone Project for the Databases Course @ University of Naples Federico II.*
