create database Amazon_Sales;
use amazon_sales;

DROP TABLE IF EXISTS sales_data;

CREATE TABLE sales_data (
    invoice_id VARCHAR(30),
    branch VARCHAR(5),
    city VARCHAR(30),
    customer_type VARCHAR(30),
    gender VARCHAR(10),
    product_line VARCHAR(100),
    unit_price DECIMAL(10,2),
    quantity INT,
    VAT FLOAT,
    total DECIMAL(10,2),
    date DATE,
    time DATETIME,
    payment_method VARCHAR(30),
    cogs DECIMAL(10,2),
    gross_margin_percentage FLOAT,
    gross_income DECIMAL(10,2),
    rating FLOAT
);
SHOW TABLES;
use amazon_sales;
SELECT * FROM sales_data LIMIT 10;

-- finding the duplicate in invoice

SELECT invoice_id, COUNT(*) 
FROM sales_data 
GROUP BY invoice_id 
HAVING COUNT(*) > 1;

-- 1) What is the count of distinct cities in the dataset?

SELECT COUNT(DISTINCT city) AS distinct_city_count
FROM sales_data;

-- 2) For each branch, what is the corresponding city?
SELECT branch, city
FROM sales_data
GROUP BY branch;


-- 3)What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT product_line) AS distinct_product_line_count
FROM sales_data;

-- 4)Which payment method occurs most frequently?
SELECT payment_method, COUNT(*) AS frequency
FROM sales_data
GROUP BY payment_method
ORDER BY frequency DESC
LIMIT 1;

-- 5)Which product line has the highest sales?
SELECT product_line, SUM(total) AS total_sales
FROM sales_data
GROUP BY product_line
ORDER BY total_sales DESC
LIMIT 1;

-- 6)How much revenue is generated each month?
SELECT MONTH(date) AS month, SUM(total) AS total_revenue
FROM sales_data
GROUP BY MONTH(date)
ORDER BY month;

-- 7)In which month did the cost of goods sold reach its peak?
SELECT MONTH(date) AS month, MAX(cogs) AS peak_cogs
FROM sales_data
GROUP BY MONTH(date)
ORDER BY peak_cogs DESC
LIMIT 1;

-- 8)Which product line generated the highest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM sales_data
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- 9)In which city was the highest revenue recorded?
SELECT city, SUM(total) AS total_revenue
FROM sales_data
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- 10)Which product line incurred the highest Value Added Tax?
SELECT product_line, SUM(VAT) AS total_vat
FROM sales_data
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

-- 11)For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT product_line,
       SUM(total) AS total_sales,
       CASE
           WHEN SUM(total) > (SELECT AVG(total) FROM sales_data) THEN 'Good'
           ELSE 'Bad'
       END AS sales_status
FROM sales_data
GROUP BY product_line;

-- 12)Identify the branch that exceeded the average number of products sold.
SELECT branch,
       SUM(quantity) AS total_products_sold
FROM sales_data
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales_data);

-- 13)Which product line is most frequently associated with each gender?
SELECT gender, product_line
FROM sales_data
GROUP BY gender, product_line
HAVING COUNT(*) = (
    SELECT MAX(product_line_count)
    FROM (
        SELECT gender, product_line, COUNT(*) AS product_line_count
        FROM sales_data
        GROUP BY gender, product_line
    ) AS counts
    WHERE counts.gender = sales_data.gender
);

-- 14)Calculate the average rating for each product line.
SELECT product_line, AVG(rating) AS average_rating
FROM sales_data
GROUP BY product_line;

ALTER TABLE sales_data ADD COLUMN timeofday VARCHAR(20);

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_data
SET timeofday = CASE
    WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(time) BETWEEN 18 AND 21 THEN 'Evening'
    ELSE 'Night'
END;

SET SQL_SAFE_UPDATES = 1;

SELECT time, timeofday FROM sales_data LIMIT 10;

-- 15)Count the sales occurrences for each time of day on every weekday.
SELECT 
    dayname(date) AS weekday, 
    timeofday, 
    COUNT(*) AS sales_count
FROM sales_data
GROUP BY dayname(date), timeofday
ORDER BY FIELD(dayname(date), 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), 
         timeofday;

-- 16)Identify the customer type contributing the highest revenue.
SELECT customer_type, 
       SUM(total) AS total_revenue
FROM sales_data
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- 17)Determine the city with the highest VAT percentage.
SELECT city, MAX(VAT) AS highest_vat_percentage
FROM sales_data
GROUP BY city
ORDER BY highest_vat_percentage DESC
LIMIT 1;

-- 18)Identify the customer type with the highest VAT payments
SELECT customer_type, MAX(VAT) AS max_vat
FROM sales_data
GROUP BY customer_type
ORDER BY max_vat DESC
LIMIT 1;

-- 19)What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT customer_type) AS distinct_customer_types
FROM sales_data;

-- 20)What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT payment_method) AS distinct_payment_methods
FROM sales_data;

-- 21)Which customer type occurs most frequently?
SELECT customer_type, COUNT(*) AS frequency
FROM sales_data
GROUP BY customer_type
ORDER BY frequency DESC
limit 1;

-- 22)Identify the customer type with the highest purchase frequency.
SELECT customer_type, COUNT(*) AS purchase_frequency
FROM sales_data
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

-- 23)Determine the predominant gender among customers.
SELECT gender, COUNT(*) AS gender_count
FROM sales_data
GROUP BY gender
ORDER BY gender_count DESC;

-- 24)Examine the distribution of genders within each branch.
SELECT branch, gender, COUNT(*) AS gender_count
FROM sales_data
GROUP BY branch, gender
ORDER BY branch, gender_count DESC;

-- 25)Identify the time of day when customers provide the most ratings.
SELECT 
    CASE 
        WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(rating) AS rating_count
FROM sales_data
WHERE rating IS NOT NULL
GROUP BY time_of_day
ORDER BY rating_count DESC
LIMIT 1;

-- 26)Determine the time of day with the highest customer ratings for each branch.
SELECT 
    branch,
    timeofday,
    COUNT(rating) AS rating_count
FROM sales_data
GROUP BY branch, timeofday
ORDER BY branch, rating_count DESC;

-- 27)Identify the day of the week with the highest average ratings.
SELECT 
    DAYNAME(date) AS weekday,
    AVG(rating) AS average_rating
FROM sales_data
GROUP BY weekday
ORDER BY average_rating DESC
LIMIT 1;

-- 28)Determine the day of the week with the highest average ratings for each branch.
SELECT 
    branch, 
    DAYNAME(date) AS weekday,
    AVG(rating) AS average_rating
FROM sales_data
GROUP BY branch, weekday
ORDER BY branch, average_rating DESC;




DESCRIBE sales_data;

SELECT 
    DAYNAME(date) AS weekday, 
    AVG(rating) AS average_rating 
FROM sales_data 
GROUP BY DAYNAME(date) 
ORDER BY average_rating DESC 
LIMIT 1;





