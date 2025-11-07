SELECT * FROM sales
---------------------------------------------------------
--Step 1 :- To check for duplicates
--Step 2 :- To Handel Duplicate
--Step 3 :- Check For Null Values
--Step 4 :- Treating Null values
--Step 5 :- Handling Negative values
--Step 6 :- Fixing Inconsistent Date Formats & Invalid Dates
--Step 7 :- Fixing Invalid Email Addresses
--Step 8 :- Checking the datatype
--------------------------------------------------------------------------------------------
--Step 1 :- To check for duplicates

with duplicate_check as(
select *,
row_number() over(partition by transaction_id order by transaction_id)as row_num
from sales
)
select * 
from duplicate_check 
where row_num > 1;

--Step 2 :-To Handel Duplicate

with duplicate_check as(
select *,
row_number() over(partition by transaction_id order by transaction_id)as row_num
from sales
)
delete
from duplicate_check 
where transaction_id in(1001,1004,1030,1074)

------------------------------------------------------------------------------------------
--Step 3 :- Check For Null Values

--this way to check null

select * 
from sales
where transaction_id is null
or customer_id is null
or customer_name is null
or email is null
or purchase_date is null
or product_id is null
or category is null
or price is null
or quantity is null
or total_amount is null
or payment_method is null
or delivery_status is null
or customer_address is null;


--or a predefined query to have a count of null which will me more easier to handel nulls

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;



--Step 4 :- Treating Null values

----- handling category
select distinct category from sales;

UPDATE sales
set category ='Unknown'
where category is null;

-----handling customer_address
UPDATE sales
set customer_address ='N/A'
where customer_address is null;

-----handling payment_method
select distinct payment_method from sales;

UPDATE sales
set payment_method ='Credit Card'
where payment_method in('CC','creditcard','credit');

UPDATE sales
set payment_method ='Cash'
where payment_method is null;

-----handling delivery_status
select distinct delivery_status from sales;

UPDATE sales
set delivery_status ='Not Delivered'
where delivery_status is null;

-----handling customer_id
 
 --we can't add anything in cutomer id as its unique for every customer

-----handling customer_name
select *
from sales
where customer_name is null;

update sales
set customer_name='User'
where customer_name is null;


-----handling price

       ----mean/average-----2510.76803817603
select avg(price)as mean from sales;
       ----mode-----  will not use because not having max price
select price,count(*) as max_count
from sales 
group by price
order by max_count desc;
       ----median----2530.75
select distinct 
    PERCENTILE_CONT(0.5) within group (order by price) over()as median
from sales;
       ----price by category----
select category ,round(avg(price),2)as avg_price
from sales
group by category;
         ---Clothing	        2539.28
         ---Toys	            2235.47
         ---Unknown	            2511.42
         ---Electronics	        2663.93 
         ---Books	            2574.46
         ---Home & Kitchen	    2507.06

        --clothing
update sales
set price =2539.28
where price is null and category='Clothing';

        --toys
update sales
set price =2235.47
where price is null and category='Toys';

        --Unknown
update sales
set price =2511.42
where price is null and category='Unknown';

        --Electronics
update sales
set price =2663.93
where price is null and category='Electronics';

        --Books
update sales
set price =2574.46
where price is null and category='Books';

        --Home & Kitchen
update sales
set price =2507.06
where price is null and category='Home & Kitchen';


------------------------------------------------------------------------------------------------


--Step 5 :- Handling Negative values
select * from sales
where quantity < 0;

update sales
set quantity=abs(quantity)
where quantity < 0;


update sales
set total_amount= price*quantity
where total_amount is null or  total_amount <> price*quantity;

--------------------------------------------------------------------------------------------------

--Step 6 :- Fixing Inconsistent Date Formats & Invalid Dates

   --- invalid_date---
select *
from sales
where purchase_date='2024-02-30';

update sales
set purchase_date=
   case 
       when TRY_CONVERT(date,purchase_date,123) is not null
       then TRY_CONVERT(date,purchase_date,123)
   else null
end;


----------------------------------------------------------------------------------------------------

--Step 7 :- Fixing Invalid Email Addresses

select *
from sales
where email not like('%@%');

update sales
set email=null
where email not like('%@%');

-----------------------------------------------------------------------------------------------------

--Step 8 :- Checking the datatype

select column_name,data_type
from INFORMATION_SCHEMA.columns
where table_name='Sales';

alter table sales
alter column purchase_date date;