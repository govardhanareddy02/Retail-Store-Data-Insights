CREATE DATABASE RETAILS;

USE RETAILS;

SELECT * FROM customer;

SELECT * FROM transactions;

SELECT * FROM prod_cat_info;

--- **************** DATA PREPARATION AND UNDERSTANDING **************************---

--- Q1 BEGIN-----------------------------------------------------------------------------------

SELECT  'customer' AS TABLE_NAME, COUNT(*) AS TOTAL_ROWS FROM retails.customer
UNION
SELECT 'transactions', COUNT(*) FROM retails.transactions
UNION
SELECT 'prod_cat_info', COUNT(*) FROM retails.prod_cat_info;

--- Q1 END-------------------------------------------------------------------------------------


--- Q2 BEGIN------------------------------------------------------------------------------------
SELECT 'RETURN' AS TRANSACTION_TYPE, COUNT(*) AS TOTAL_RETURN_TRANSACTION
FROM Transactions
WHERE Qty < 0;

--- Q2 END--------------------------------------------------------------------------------------


--- Q3 BEGIN------------------------------------------------------------------------------------
SELECT customer_id, STR_TO_DATE(DOB, '%d-%m-%y') AS NEW_FORMAT_DATE FROM customer;

SELECT transaction_id, STR_TO_DATE(tran_date, '%d-%m-%Y') AS NEW_FORMAT_TRAN_DATE
FROM Transactions;

--- Q3 END--------------------------------------------------------------------------------------


--- Q4 BEGIN------------------------------------------------------------------------------------
SELECT 
    MIN(STR_TO_DATE(tran_date, '%d-%m-%Y')) AS BEGIN_TRANSACTION_DATE,
    MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')) AS END_TRANSACTION_DATE,
    DATEDIFF(MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')), MIN(STR_TO_DATE(tran_date, '%d-%m-%Y'))) AS NUMBER_OF_DAYS,
    TIMESTAMPDIFF(MONTH, MIN(STR_TO_DATE(tran_date, '%d-%m-%Y')), MAX(STR_TO_DATE(tran_date, '%d-%m-%Y'))) AS NUMBER_OF_MONTHS,
    TIMESTAMPDIFF(YEAR, MIN(STR_TO_DATE(tran_date, '%d-%m-%Y')), MAX(STR_TO_DATE(tran_date, '%d-%m-%Y'))) AS NUMBER_OF_YEARS
FROM Transactions;

--- Q4 END------------------------------------------------------------------------------------


--- Q5 BEGIN------------------------------------------------------------------------------------
SELECT prod_cat 
FROM prod_cat_info
WHERE prod_subcat = 'DIY';

--- Q5 END------------------------------------------------------------------------------------

--- ********************************** DATA ANALYSIS *******************************************---

--- Q1 BEGIN------------------------------------------------------------------------------------
SELECT Store_type AS CHANNELS, COUNT(*) AS TOTAL_TRANSACTIONS
FROM Transactions
GROUP BY Store_type
ORDER BY TOTAL_TRANSACTIONS DESC
LIMIT 1;

--- Q1 END------------------------------------------------------------------------------------


--- Q2 BEGIN------------------------------------------------------------------------------------

SELECT Gender, COUNT(*) AS TOTAL_COUNT
FROM Customer
WHERE Gender IN ('M', 'F')
GROUP BY Gender;

--- Q2 END------------------------------------------------------------------------------------


--- Q3 BEGIN------------------------------------------------------------------------------------

SELECT city_code, COUNT(*) AS MAX_CUSTOMER
FROM Customer
GROUP BY city_code
ORDER BY MAX_CUSTOMER DESC
LIMIT 1;

--- Q3 END------------------------------------------------------------------------------------


--- Q4 BEGIN------------------------------------------------------------------------------------

SELECT prod_cat, COUNT(prod_subcat) AS COUNT_OF_SUB_CAT_OF_BOOK
FROM prod_cat_info
WHERE prod_cat LIKE 'Books' GROUP BY prod_cat;

--- Q4 END------------------------------------------------------------------------------------


--- Q5 BEGIN------------------------------------------------------------------------------------
SELECT TA.prod_cat_code AS PRODUCT_CATEGORY_CODE, prod_cat AS PRODUCT_CATEGORY, 
       MAX(Qty) AS MAX_QUANTITY
FROM Transactions AS TA
JOIN prod_cat_info AS PCI
    ON TA.prod_cat_code = PCI.prod_cat_code 
    AND TA.prod_subcat_code = PCI.prod_sub_cat_code
GROUP BY TA.prod_cat_code, prod_cat
ORDER BY MAX_QUANTITY DESC
LIMIT 1;

--- Q5 END------------------------------------------------------------------------------------


--- Q6 BEGIN------------------------------------------------------------------------------------
SELECT PCI.prod_cat AS PRODUCT_CATEGORY, SUM(total_amt) AS TOTAL_REVENUE
FROM Transactions AS TR
JOIN prod_cat_info AS PCI
    ON TR.prod_cat_code = PCI.prod_cat_code 
    AND TR.prod_subcat_code = PCI.prod_sub_cat_code
WHERE PCI.prod_cat IN ('Books', 'Electronics')
GROUP BY PCI.prod_cat;

--- Q6 END------------------------------------------------------------------------------------


--- Q7 BEGIN------------------------------------------------------------------------------------
SELECT cust_id AS CUSTOMER_ID, COUNT(*) AS TOTAL_NUMBER_OF_TRANSACTIONS
FROM Transactions
WHERE Qty > 0
GROUP BY cust_id
HAVING COUNT(*) > 10;

--- Q7 END------------------------------------------------------------------------------------


--- Q8 BEGIN-----------------------------------------------------------------------------------
SELECT prod_cat AS PRODUCT_CATEGORY, SUM(total_amt) AS TOTAL_AMT
FROM Transactions AS TR
JOIN prod_cat_info AS PCI
    ON TR.prod_cat_code = PCI.prod_cat_code 
    AND TR.prod_subcat_code = PCI.prod_sub_cat_code
WHERE Store_type = 'Flagship store' 
  AND PROD_CAT IN ('Clothing', 'Electronics')
GROUP BY prod_cat
UNION ALL
SELECT 'GRAND TOTAL', SUM(TOTAL_AMT)
FROM (
    SELECT prod_cat, SUM(total_amt) AS TOTAL_AMT
    FROM Transactions AS TR
    JOIN prod_cat_info AS PCI
        ON TR.prod_cat_code = PCI.prod_cat_code 
        AND TR.prod_subcat_code = PCI.prod_sub_cat_code
    WHERE Store_type = 'Flagship store' 
      AND PROD_CAT IN ('Clothing', 'Electronics')
    GROUP BY prod_cat
) AS T1;

--- Q8 END-----------------------------------------------------------------------------------


--- Q9 BEGIN-----------------------------------------------------------------------------------
SELECT Gender, prod_cat, prod_subcat, SUM(total_amt) AS TOTAL_REVENUE
FROM Customer AS C
JOIN Transactions AS TR
    ON C.customer_Id = TR.cust_id 
JOIN prod_cat_info AS PCI 
    ON TR.prod_cat_code = PCI.prod_cat_code 
    AND TR.prod_subcat_code = PCI.prod_sub_cat_code
WHERE Gender = 'M' 
  AND prod_cat = 'Electronics'
GROUP BY Gender, prod_cat, prod_subcat;

--- Q9 END-----------------------------------------------------------------------------------

--- Q10 BEGIN-----------------------------------------------------------------------------------
SELECT prod_subcat AS PRODUCT_SUB_CATEGORY, 
       SUM(total_amt) AS TOTAL_SALES,
       (SUM(total_amt) / (SELECT SUM(total_amt) FROM Transactions)) * 100 AS TOTAL_SALES_PERCENTAGE,
       (SUM(CASE WHEN Qty < 0 THEN Qty ELSE 0 END) / 
        (SELECT SUM(Qty) FROM Transactions WHERE Qty < 0)) * 100 AS TOTAL_RETURNS_PERCENTAGE
FROM Transactions AS TR
JOIN prod_cat_info AS PCI
    ON TR.prod_cat_code = PCI.prod_cat_code 
    AND TR.prod_subcat_code = PCI.prod_sub_cat_code
GROUP BY prod_subcat
ORDER BY TOTAL_SALES DESC
LIMIT 5;

--- Q15 END---------------------------------------------------------------------------------
