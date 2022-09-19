use orders;

select * from address;
select * from carton;
select * from online_customer;
select * from order_header;
select * from order_items;
select * from product;
select * from product_class;
select * from shipper;

/* QUESTION 1  */

SELECT PRODUCT_CLASS_CODE, PRODUCT_ID, PRODUCT_DESC, PRODUCT_PRICE, 
CASE PRODUCT_CLASS_CODE
  WHEN 2050 THEN PRODUCT_PRICE+2000
  WHEN 2051 THEN PRODUCT_PRICE+500
  WHEN 2052 THEN PRODUCT_PRICE+600
ELSE PRODUCT_PRICE
END AS PRICE_UPDATE FROM PRODUCT ORDER BY PRODUCT_CLASS_CODE DESC;

/* QUESTION 2 */

SELECT pc.PRODUCT_CLASS_DESC, p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL,
    CASE WHEN p.PRODUCT_QUANTITY_AVAIL = 0 THEN 'Out of stock'
         WHEN pc.PRODUCT_CLASS_DESC in ('Electronics','Computer') THEN
         CASE WHEN p.PRODUCT_QUANTITY_AVAIL <= 10 THEN 'Low stock'
              WHEN p.PRODUCT_QUANTITY_AVAIL BETWEEN 11 AND 30 THEN 'In stock'
              WHEN p.PRODUCT_QUANTITY_AVAIL >= 31 THEN 'Enough stock'
         END 
         WHEN pc.PRODUCT_CLASS_DESC in ('Stationery','Clothes') THEN
         CASE WHEN p.PRODUCT_QUANTITY_AVAIL <= 20 THEN 'Low stock'
              WHEN p.PRODUCT_QUANTITY_AVAIL BETWEEN 21 AND 80 THEN 'In stock'
              WHEN p.PRODUCT_QUANTITY_AVAIL >= 81 THEN 'Enough stock'
         END
         WHEN pc.PRODUCT_CLASS_DESC not in ('Stationery','Clothes', 'Electronics','Computer') THEN
         CASE WHEN p.PRODUCT_QUANTITY_AVAIL <= 15 THEN 'Low stock'
              WHEN p.PRODUCT_QUANTITY_AVAIL BETWEEN 16 AND 50 THEN 'In stock'
              WHEN p.PRODUCT_QUANTITY_AVAIL >= 51 THEN 'Enough stock'
         END
    END AS STATUS FROM PRODUCT p inner join PRODUCT_CLASS pc on PRODUCT_ID = PRODUCT_ID;
    
/* QUESTION 3 */

select count(city) as city_count, country from address group by country having city_count>1 and country!='USA' and country!='Malaysia' order by city desc;

/* QUESTION 4 */

select OC.CUSTOMER_ID, concat (OC.CUSTOMER_FNAME,' ',OC.CUSTOMER_LNAME) as CUSTOMER_FULL_NAME, A.CITY, A.PINCODE, OH.ORDER_ID, 
PC.PRODUCT_CLASS_DESC, P.PRODUCT_DESC, (OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) as SUB_TOTAL 
from ONLINE_CUSTOMER OC 
      inner join ADDRESS A on OC.ADDRESS_ID = A.ADDRESS_ID
      inner join ORDER_HEADER OH on OH.CUSTOMER_ID = OC.CUSTOMER_ID
      inner join ORDER_ITEMS OI on OI.ORDER_ID = OH.ORDER_ID
      inner join PRODUCT P on P.PRODUCT_ID = OI.PRODUCT_ID
      inner join PRODUCT_CLASS PC on PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE 
where OH.ORDER_STATUS = 'Shipped' and A.PINCODE not like '%0%'
order by CUSTOMER_FULL_NAME, SUB_TOTAL;

/* QUESTION 5 */

select P.PRODUCT_ID, P.PRODUCT_DESC, sum(OI.PRODUCT_QUANTITY) as TOTAL_QUANTITY
from ORDER_ITEMS OI 
	 inner join PRODUCT P on OI.PRODUCT_ID = P.PRODUCT_ID
     where OI.ORDER_ID in (select distinct ORDER_ID from ORDER_ITEMS OS where PRODUCT_ID = 201) and OI.PRODUCT_ID <> 201
     group by OI.PRODUCT_ID
     order by TOTAL_QUANTITY desc limit 1;
     
/* QUESTION 6 */

select oc.customer_id, concat(oc.customer_fname,'',oc.customer_lname) as customer_name, oc.customer_email, 
oi.order_id, p.product_desc, oi.product_quantity, (p.product_price * oi.product_quantity) as subtotal 
from online_customer oc
      left join ORDER_HEADER OH on OC.CUSTOMER_ID = OH.CUSTOMER_ID 
      left join ORDER_ITEMS OI on OH.ORDER_ID = OI.ORDER_ID
      left join PRODUCT P on OI.PRODUCT_ID = P.PRODUCT_ID;
      
/* QUESTION 7 */

select c.carton_id, (c.len * c.width * c.height) as carton_vol 
from orders.carton c
	where (c.len * c.width * c.height)>= (select sum(p.len * p.width * p.height * oi.product_quantity) as volume
	from orders.order_items oi 
    inner join orders.product p on oi.product_id = p.product_id 
    where order_id = 10006)
order by carton_vol asc limit 1;
     
/* QUESTION 8 */

select oc.customer_id, concat (oc.customer_fname,' ',oc.customer_lname) as Customer_name, oh.order_id, oi.product_quantity , sum(oi.product_quantity) as total_qty 
from online_customer oc 
	inner join order_header oh on oh.customer_id = oc.customer_id 
    inner join order_items oi on oh.order_id = oi.order_id 
where oh.payment_mode in ('Credit Card' , 'Net Banking') and oh.order_status = 'Shipped'
group by oh.order_id
having total_qty > 10 
order by customer_id ; 

/* QUESTION 9 */

select oi.order_id, oc.customer_id, concat(oc.customer_fname,' ',oc.customer_lname) as customer_fullname, 
sum(oi.product_quantity) as total_qty 
from online_customer oc 
    inner join order_header oh on oc.customer_id = oh.customer_id
	inner join order_items oi on oh.order_id = oi.order_id
where oh.order_status= 'Shipped' and  oc.customer_fname like 'A%'
group by oh.order_id
having oh.order_id > 10030
order by order_id ;

/* QUESTION 10 */

select PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC, sum(OI.PRODUCT_QUANTITY) as TOTAL_QUANTITY, sum(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) as TOTAL_VALUE
from ORDER_ITEMS OI
          inner join ORDER_HEADER OH on OI.ORDER_ID = OH.ORDER_ID
          inner join PRODUCT P on P.PRODUCT_ID = OI.PRODUCT_ID
          inner join ONLINE_CUSTOMER OC on OH.CUSTOMER_ID = OC.CUSTOMER_ID
          inner join PRODUCT_CLASS PC on PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
          inner join ADDRESS A on A.ADDRESS_ID = OC.ADDRESS_ID
 where OH.ORDER_STATUS ='Shipped' AND A.COUNTRY NOT IN ('India','USA')  
group by PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC
order by TOTAL_QUANTITY desc limit 1;

