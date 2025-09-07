select top 5 * from dbo.sales_;
select top 5 * from dbo.purchases;
select top 5 * from dbo.purchase_prices;
select top 5 * from dbo.end_inventory;
select top 5 * from dbo.vendor_invoice;

use project
EXEC sp_help 'dbo.sales_';
ALTER TABLE dbo.purchases
ALTER COLUMN InventoryId VARCHAR(50) NOT NULL;
CREATE INDEX idx_sales_inventory ON dbo.sales_(InventoryId);
CREATE INDEX idx_purchases_inventory ON dbo.purchases(InventoryId);
create index quantity_purchase on dbo.purchases(Quantity);
select distinct top 20 s.Description,s.VendorName
,p.Size,p.Quantity
from dbo.sales_ as s
join dbo.purchases as p
on s.InventoryId=p.InventoryId
order by p.Quantity;

-- “Top 20 Products by Total Sales Quantity”

select top 20
s.Description,
sum(p.Quantity) as total_sales
from sales_ as s
join purchases as p
on s.InventoryId=p.InventoryId
group by s.Description
order by sum(p.Quantity)  desc
;


-- Which are the Top 20 Products by Total Sales Revenue

select top 20 InventoryId ,sum(SalesDollars) as total_sales
from sales_ 
group by InventoryId 
order by sum(SalesDollars) desc;

-- What are the monthly sales trends for the last year?


select 
month(SalesDate) as month_,sum(SalesDollars) as total_sales
from sales_
where SalesDate between '2024-01-01' and '2024-12-31'
group by MONTH(SalesDate)
order by sum(SalesDollars) desc;

-- Which vendors supply the highest number of products?

select  top 10 
p.VendorName,
sum(p.Quantity) as total_sales ,
sum(v.Dollars) as total_revenue
from purchases as p
join vendor_invoice as v
on p.VendorNumber=v.VendorNumber
group by p.VendorName
order by sum(p.Quantity) desc

-- What is the total purchase cost from each vendor?
-- (Tables: purchases, purchase_prices, vendor_invoice)
select top 10 p.VendorNumber ,
sum(p.PurchasePrice * p.Quantity) as total_pc,
pp.VendorName
from purchases as p
join purchase_prices as pp
on p.VendorNumber=pp.VendorNumber
join vendor_invoice as vi
on pp.VendorNumber=vi.VendorNumber
group by p.VendorNumber ,pp.VendorName

order by sum(p.PurchasePrice) desc;

-- top 10 most profitable products


SELECT TOP 10
    s.InventoryId,
    SUM(s.SalesDollars) AS TotalSales,
    SUM(p.PurchasePrice) AS TotalCost,
    (SUM(s.SalesDollars) - SUM(p.PurchasePrice)) AS Profit
FROM sales_ s
JOIN purchases p 
    ON s.InventoryId = p.InventoryId
GROUP BY s.InventoryId
ORDER BY Profit DESC;

