
-- 1( چند سفارش در مجموع ثبت شدهاست؟

SELECT COUNT (orderid) sum_orders 
    FROM orders

-- 2( درآمد حاصل از این سفارشها چقدر بوده است؟

SELECT SUM (od.QUANTITY * p.PRICE)
  FROM orderdetails od LEFT JOIN products p ON od.PRODUCTID = p.PRODUCTID

-- 3(   5 مشتری برتر را بر اساس مقداری که خرج کردهاند پیدا کنید
--

SELECT *
  FROM (  SELECT c.CUSTOMERID,
                 c.CUSTOMERNAME,
                 SUM ((od.QUANTITY * p.PRICE))     customer_purchases
            FROM customers c
                 RIGHT JOIN orders o ON o.CUSTOMERID = c.CUSTOMERID
                 JOIN orderdetails od ON o.ORDERID = od.ORDERID
                 LEFT JOIN products p ON od.PRODUCTID = p.PRODUCTID
        GROUP BY c.CUSTOMERID, c.CUSTOMERNAME
        ORDER BY customer_purchases DESC)
 WHERE ROWNUM <= 5

 -- 4) میانگین هزینه ی سفارشات هر مشتری را به همراه ID و نام او گزارش کنید.

SELECT c.CUSTOMERID, c.CUSTOMERNAME, AVG (od.QUANTITY * p.PRICE) CUSTOMER_AVG
  FROM customers c
      RIGHT JOIN orders o ON o.CUSTOMERID = c.CUSTOMERID
      JOIN orderdetails od ON o.ORDERID = od.ORDERID
      LEFT JOIN products p ON od.PRODUCTID = p.PRODUCTID
GROUP BY c.CUSTOMERID, c.CUSTOMERNAME
ORDER BY CUSTOMER_AVG

-- 5) مشتری ان را بر اساس مقدار کل هزینهی سفارشات رتبهبندی کنید

SELECT RANK () OVER (ORDER BY CUSTOMER_PURCHASES DESC)     AS RANK,
       CUSTOMERNAME,
       CUSTOMER_PURCHASES,
       CUSTOMERID
  FROM (  SELECT c.CUSTOMERID,
                 c.CUSTOMERNAME,
                 COUNT (od.ORDERID)                number_of_order,
                 SUM ((od.QUANTITY * p.PRICE))     customer_purchases
            FROM customers c
                 RIGHT JOIN orders o ON o.CUSTOMERID = c.CUSTOMERID
                 JOIN orderdetails od ON o.ORDERID = od.ORDERID
                 LEFT JOIN products p ON od.PRODUCTID = p.PRODUCTID
        GROUP BY c.CUSTOMERID, c.CUSTOMERNAME
        ORDER BY customer_purchases DESC)
 WHERE number_of_order >= 5
 --bayad behesh index ham ezaf koni
 --emal shod vli byayd behine bshe

-- 6) کدام محصول در کل سفارشات ثبت شده بیشترین درآمد را ایجاد کرده است؟

SELECT p.PRODUCTID, p.PRODUCTNAME, SUM (p.PRICE * od.QUANTITY) selling_sum
  FROM products p JOIN orderdetails od ON p.PRODUCTID = od.PRODUCTID
GROUP BY p.PRODUCTID, p.PRODUCTNAME
ORDER BY selling_sum DESC

-- 7)

  SELECT p.CATEGORYID, COUNT (p.PRODUCTID) count_product
    FROM products p
GROUP BY p.CATEGORYID
ORDER BY COUNT (p.PRODUCTID)

-- 8) محصول پرفروش در هر دسته بر اساس درآمد را تعیین کنید.

WITH
    table1
    AS
        (  SELECT p.PRODUCTID,
                  p.PRODUCTNAME,
                  p.CATEGORYID,
                  SUM (p.PRICE * od.QUANTITY)     AS selling_sum
             FROM products p JOIN orderdetails od ON p.PRODUCTID = od.PRODUCTID
         GROUP BY p.PRODUCTID, p.PRODUCTNAME, p.CATEGORYID),
    table_1
    AS
        (SELECT CATEGORYID,
                MAX (selling_sum) OVER (PARTITION BY CATEGORYID)     AS sum_1
           FROM table1),
    table_2
    AS
        (  SELECT CATEGORYID, AVG (sum_1) AS max_selling_of_eash_category
             FROM table_1
         GROUP BY CATEGORYID)
SELECT t2.CATEGORYID, t1.PRODUCTID, t2.max_selling_of_eash_category
  FROM table_2  t2
       LEFT JOIN table1 t1
           ON t2.max_selling_of_eash_category = t1.SELLING_SUM

-- 9)  5 کارمند برتر که باالترین درآمد را ایجاد کردند

  SELECT e.EMPLOYEEID,
         e.FIRSTNAME,
         e.LASTNAME,
         SUM (od.QUANTITY * p.PRICE)     income_from
    FROM EMPLOYEES e
         JOIN orders o ON e.EMPLOYEEID = o.EMPLOYEEID
         JOIN orderdetails od ON o.ORDERID = od.ORDERID
         JOIN products p ON od.PRODUCTID = p.PRODUCTID
GROUP BY e.EMPLOYEEID, e.FIRSTNAME, e.LASTNAME

-- 10) 

  SELECT e.EMPLOYEEID, AVG (od.QUANTITY * p.PRICE) avg_income_from
    FROM EMPLOYEES e
         JOIN orders o ON e.EMPLOYEEID = o.EMPLOYEEID
         JOIN orderdetails od ON o.ORDERID = od.ORDERID
         JOIN products p ON od.PRODUCTID = p.PRODUCTID
GROUP BY e.EMPLOYEEID
ORDER BY avg_income_from

-- 11) کدام کشور بیشترین تعداد سفارشات را ثبت کرده است؟

  SELECT c.COUNTRY, COUNT (o.ORDERID) count_orders
    FROM customers c JOIN orders o ON c.CUSTOMERID = o.CUSTOMERID
GROUP BY c.COUNTRY
ORDER BY count_orders DESC

-- 12) مجموع درآمد از سفارشات هر کشور چقدر بوده؟ 

  SELECT c.COUNTRY, SUM (od.QUANTITY * p.PRICE) income_from
    FROM customers c
         JOIN orders o ON c.CUSTOMERID = o.CUSTOMERID
         JOIN orderdetails od ON o.ORDERID = od.ORDERID
         JOIN products p ON od.PRODUCTID = p.PRODUCTID
GROUP BY c.COUNTRY
ORDER BY income_from

-- 13)  میانگین قیمت هر دسته چقدر است؟

  SELECT c.CATEGORYID, c.CATEGORYNAME, AVG (p.PRICE) avg_price
    FROM CATEGORIES c JOIN products p ON c.CATEGORYID = p.CATEGORYID
GROUP BY c.CATEGORYID, c.CATEGORYNAME
ORDER BY avg_price

-- 14) گران ترین دسته بندی کدام است؟

  SELECT c.CATEGORYID, c.CATEGORYNAME, max (p.PRICE) max_price
    FROM CATEGORIES c JOIN products p ON c.CATEGORYID = p.CATEGORYID
GROUP BY c.CATEGORYID, c.CATEGORYNAME
ORDER BY max_price desc

-- 15) طی سال 1996 هر ماه چند سفارش ثبت شده است؟

  SELECT EXTRACT (MONTH FROM o.ORDERDATE), COUNT (o.ORDERID)
    FROM orders o
   WHERE EXTRACT (YEAR FROM o.ORDERDATE) = 1996
GROUP BY EXTRACT (MONTH FROM o.ORDERDATE)

-- 16) میانگین فاصله ی زمانی بین سفارشات هر مشتری چقدر بوده؟ 

  SELECT CUSTOMERID,
         CUSTOMERNAME,
         AVG (daysincelastorder)     avg_daysincelastorder
    FROM (SELECT o.CUSTOMERID,
                 o.ORDERID,
                 o.ORDERDATE,
                 c.CUSTOMERNAME,
                   o.ORDERDATE
                 - LAG (o.ORDERDATE)
                       OVER (PARTITION BY o.CUSTOMERID ORDER BY o.ORDERDATE)    AS daysincelastorder
            FROM orders o JOIN customers c ON o.CUSTOMERID = c.CUSTOMERID)
GROUP BY CUSTOMERID, CUSTOMERNAME
ORDER BY avg_daysincelastorder

-- 17) در هر فصل جمع سفارشات چقدر بودهاست؟

  SELECT Season, COUNT (ORDERID)
    FROM (SELECT o.ORDERID,
                 CASE
                     WHEN EXTRACT (MONTH FROM o.ORDERDATE) IN (12, 1, 2)
                     THEN
                         'Winter'
                     WHEN EXTRACT (MONTH FROM o.ORDERDATE) IN (3, 4, 5)
                     THEN
                         'Spring'
                     WHEN EXTRACT (MONTH FROM o.ORDERDATE) IN (6, 7, 8)
                     THEN
                         'Summer'
                     WHEN EXTRACT (MONTH FROM o.ORDERDATE) IN (9, 10, 11)
                     THEN
                         'Fall'
                 END    AS Season
            FROM orders o)
GROUP BY Season
ORDER BY COUNT (ORDERID)

-- 18) کدام تامین کننده بیشترین تعداد کاال را تامین کرده است؟

  SELECT s.SUPPLIERID, s.SUPPLIERNAME, COUNT (p.PRODUCTID) Sum_of_products
    FROM suppliers s JOIN products p ON s.SUPPLIERID = p.SUPPLIERID
GROUP BY s.SUPPLIERID, s.SUPPLIERNAME
ORDER BY COUNT (p.PRODUCTID) DESC

-- 19) میانگین قیمت کاالی تامین شده توسط هر تامیکننده چقدر بوده؟ 

  SELECT s.SUPPLIERID, s.SUPPLIERNAME, AVG (p.PRICE)
    FROM suppliers s JOIN products p ON s.SUPPLIERID = p.SUPPLIERID
GROUP BY s.SUPPLIERID, s.SUPPLIERNAME
ORDER BY AVG (p.PRICE)