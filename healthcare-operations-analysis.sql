-- ========================================
-- HEALTHCARE OPERATIONS ANALYSIS
-- SQL Portfolio Project
-- ========================================

-- Table: healthcare_operations_project




-- ========================================
-- DATA VALIDATION
-- ========================================

-- Row count + date range
SELECT
  COUNT(*) AS total_encounters,
  MIN(admit_date) AS min_admit_date,
  MAX(admit_date) AS max_admit_date
FROM healthcare_operations_project;

-- Check for nulls in key numeric fields
SELECT
  SUM(CASE WHEN treatment_cost_usd IS NULL THEN 1 ELSE 0 END) AS null_treatment_cost,
  SUM(CASE WHEN length_of_stay_days IS NULL THEN 1 ELSE 0 END) AS null_length_of_stay,
  SUM(CASE WHEN readmission_30d_flag IS NULL THEN 1 ELSE 0 END) AS null_readmission_flag,
  SUM(CASE WHEN patient_satisfaction_score IS NULL THEN 1 ELSE 0 END) AS null_satisfaction,
  SUM(CASE WHEN bed_occupancy_rate IS NULL THEN 1 ELSE 0 END) AS null_bed_occupancy
FROM healthcare_operations_project;


-- ========================================
-- EXECUTIVE KPIs (matches Excel/Power BI measures)
-- ========================================

SELECT
  SUM(treatment_cost_usd) AS total_treatment_cost,
  COUNT(*) AS total_encounters,
  AVG(length_of_stay_days) AS avg_length_of_stay_days,
  AVG(readmission_30d_flag) AS readmission_rate,              -- 0/1 average
  AVG(patient_satisfaction_score) AS avg_satisfaction_score,
  AVG(bed_occupancy_rate) AS avg_bed_occupancy_rate           -- 0-1 scale
FROM healthcare_operations_project;


-- SELECT
--   ROUND(SUM(treatment_cost_usd), 2) AS total_treatment_cost,
--   COUNT(*) AS total_encounters,
--   ROUND(AVG(length_of_stay_days), 2) AS avg_length_of_stay_days,
--   ROUND(AVG(readmission_30d_flag) * 100.0, 2) AS readmission_rate_pct,
--   ROUND(AVG(patient_satisfaction_score), 2) AS avg_satisfaction_score,
--   ROUND(AVG(bed_occupancy_rate) * 100.0, 2) AS avg_bed_occupancy_rate_pct
-- FROM healthcare_operations_project;


-- ========================================
-- COST ANALYSIS
-- ========================================

-- Total treatment cost by department (Excel pivot equivalent)
SELECT
  department,
  SUM(treatment_cost_usd) AS total_treatment_cost
FROM healthcare_operations_project
GROUP BY department
ORDER BY total_treatment_cost DESC;

-- Cost + volume by hospital
SELECT
  hospital,
  COUNT(*) AS total_encounters,
  SUM(treatment_cost_usd) AS total_treatment_cost,
  AVG(treatment_cost_usd) AS avg_treatment_cost
FROM healthcare_operations_project
GROUP BY hospital
ORDER BY total_treatment_cost DESC;

-- Cost by diagnosis group (helps explain cost drivers)
SELECT
  diagnosis_group,
  COUNT(*) AS total_encounters,
  SUM(treatment_cost_usd) AS total_treatment_cost,
  AVG(treatment_cost_usd) AS avg_treatment_cost
FROM healthcare_operations_project
GROUP BY diagnosis_group
ORDER BY total_treatment_cost DESC;


-- ========================================
-- EFFICIENCY (LOS)
-- ========================================

-- Average length of stay by department & admission type
SELECT
  department,
  admission_type,
  COUNT(*) AS total_encounters,
  AVG(length_of_stay_days) AS avg_length_of_stay_days
FROM healthcare_operations_project
GROUP BY department, admission_type
ORDER BY department, admission_type;

-- Length of stay by hospital (quick ops comparison)
SELECT
  hospital,
  COUNT(*) AS total_encounters,
  AVG(length_of_stay_days) AS avg_length_of_stay_days
FROM healthcare_operations_project
GROUP BY hospital
ORDER BY avg_length_of_stay_days DESC;


-- ========================================
-- QUALITY (READMISSIONS)
-- ========================================

-- Readmission rate by diagnosis group
SELECT
  diagnosis_group,
  COUNT(*) AS total_encounters,
  AVG(readmission_30d_flag) AS readmission_rate
FROM healthcare_operations_project
GROUP BY diagnosis_group
ORDER BY readmission_rate DESC;

-- Readmission rate by department
SELECT
  department,
  COUNT(*) AS total_encounters,
  AVG(readmission_30d_flag) AS readmission_rate
FROM healthcare_operations_project
GROUP BY department
ORDER BY readmission_rate DESC;

-- Readmission segmentation (avoid tiny groups with HAVING)
SELECT
  age_group,
  diagnosis_group,
  COUNT(*) AS total_encounters,
  AVG(readmission_30d_flag) AS readmission_rate
FROM healthcare_operations_project
GROUP BY age_group, diagnosis_group
HAVING COUNT(*) >= 20
ORDER BY readmission_rate DESC;


-- ========================================
-- PATIENT EXPERIENCE (SATISFACTION)
-- ========================================

-- Satisfaction by department & hospital (Excel pivot equivalent)
SELECT
  department,
  hospital,
  COUNT(*) AS total_encounters,
  AVG(patient_satisfaction_score) AS avg_satisfaction_score
FROM healthcare_operations_project
GROUP BY department, hospital
ORDER BY department, avg_satisfaction_score DESC;

-- Satisfaction by admission type
SELECT
  admission_type,
  COUNT(*) AS total_encounters,
  AVG(patient_satisfaction_score) AS avg_satisfaction_score
FROM healthcare_operations_project
GROUP BY admission_type
ORDER BY avg_satisfaction_score DESC;


-- ========================================
-- CAPACITY (BED OCCUPANCY)
-- ========================================

-- Bed occupancy by hospital & department
SELECT
  hospital,
  department,
  COUNT(*) AS total_encounters,
  AVG(bed_occupancy_rate) AS avg_bed_occupancy_rate
FROM healthcare_operations_project
GROUP BY hospital, department
ORDER BY hospital, avg_bed_occupancy_rate DESC;


-- ========================================
-- COST EFFICIENCY (ADVANCED METRIC)
-- ========================================

-- Avg cost per day by department (NULLIF prevents divide-by-zero)
SELECT
  department,
  COUNT(*) AS total_encounters,
  AVG(treatment_cost_usd / NULLIF(length_of_stay_days, 0)) AS avg_cost_per_day
FROM healthcare_operations_project
GROUP BY department
ORDER BY avg_cost_per_day DESC;


-- ========================================
-- TRENDS (MONTHLY)
-- ========================================

-- Monthly trends using admit_month (already in your Excel data)
SELECT
  admit_month,
  COUNT(*) AS total_encounters,
  SUM(treatment_cost_usd) AS total_treatment_cost,
  AVG(length_of_stay_days) AS avg_length_of_stay_days,
  AVG(readmission_30d_flag) AS readmission_rate
FROM healthcare_operations_project
GROUP BY admit_month
ORDER BY admit_month;


-- ========================================
-- OUTLIERS / INVESTIGATION
-- ========================================

-- Top 10 highest-cost encounters
SELECT
  encounter_id,
  hospital,
  department,
  diagnosis_group,
  length_of_stay_days,
  treatment_cost_usd,
  readmission_30d_flag,
  patient_satisfaction_score
FROM healthcare_operations_project
ORDER BY treatment_cost_usd DESC
LIMIT 10;
