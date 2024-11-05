--(Project Music Database)

--------------------------------------------EASY SET-------------------------------------------------------------------

-- Q:(Senior Most Employee Based on title) = (Mohan Madan/Sr. General Manager)

select first_name, last_name,title,levels 
from employee
order by levels desc 
limit 1;

--Q:(Country with most invoices) = (USA)
select billing_country as country, count(billing_country)Total_invoices 
from invoice
group by country
order by 2 desc
limit 1;

--Q:(Top 3 purchases value from invoices) =(25.76, 19.8, 19.8)
select total 
from invoice
order by 1 desc
limit 3;

--Q:(City which from which made the most money) = (Prague)
select customer.city,  sum(invoice.total) as T 
from invoice
join customer on invoice.customer_id=customer.customer_id
group by 1
order by 2 desc 
limit 1 ;

--Q:(Customer who spent most money) = (Fynn Zimmemann)
select customer.first_name, customer.last_name,  sum(invoice.total) as T 
from invoice
join customer on invoice.customer_id=customer.customer_id
group by 1,2
order by 3 desc 
limit 1 ;

-------------------------------------------------MEDIUM SET---------------------------------------------------------------

--Q:(Query that returns first name, last name, email and genre of all ROCK music listeners.
--	 Arrange email in alphabetically order.)

select customer.first_name as fname, customer.last_name as lname,customer.email as email, genre.name as gen 
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by 1,2,3,4
order by 3 asc;

--Another query to do this.
select customer.first_name as fname, customer.last_name as lname,customer.email as email 
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id In(
	select track_id from track
	join genre on track.genre_id=genre.genre_id
	where genre.name like 'Rock'
)
group by 1,2,3
order by 3;

--Q:2 (write a query that returns those artist who have written most rock music tracks)

select artist.name as Artist_name, genre.name as gen, count(genre.name) as Num 
from artist
join album on album.artist_id= artist.artist_id
join track on track.album_id=album.album_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by 1,2 
order by num desc
limit 10;

--Q:3 (Return all songs names that have song length length longer than average)

select name,milliseconds 
from track
where milliseconds>(
	select avg(milliseconds) 
	from track
)
order by 2 desc;

-----------------------------------------------------HARD SET----------------------------------------------------------------
--Q: ( Query that returns those customer who spent highest on which genre )
select customer.first_name, customer.last_name,artist.name,sum(track.unit_price) 
from customer
join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join album on track.album_id=album.album_id
join artist on artist.artist_id=album.artist_id
group by 1,2,3
order by 4 desc;

--( QUERY that reutrns most popular genre from each country based on highest count of purchases)
with ct as(
select count(invoice_line.quantity) as purchases, customer.country, genre.name, 
row_number() over(partition by customer.country  order by count(invoice_line.quantity) desc) as row_no
from invoice_line
join invoice on invoice.invoice_id=invoice_line.invoice_id
join customer on customer.customer_id=invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on track.genre_id = genre.genre_id
group by 2,3
order by 1 desc
)
select * from ct where row_no <= 1;
--(Another Method)
with recursive pop as(
select invoice.billing_country as country, genre.name as gen, genre.genre_id as gen_id, count(*) as highest_purchase_count
from invoice_line
join invoice on invoice.invoice_id=invoice_line.invoice_id
join customer on customer.customer_id=invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on track.genre_id = genre.genre_id
group by 1,2,3
order by 1 asc, 4 desc
),
max_count as(
	select max(highest_purchase_count) as cont, pop.country 
	from pop
	group by 2
)
select pop.* from pop
join max_count on max_count.country=pop.country
where pop.highest_purchase_count =max_count.cont;

--Q: (query that returns customers from each country who spent most on music)
with recursive cte as(
select  customer.customer_id, customer.first_name, customer.last_name,invoice.billing_country as country, Sum(invoice.total) total 
from customer
join invoice on customer.customer_id=invoice.customer_id 
group by 1,2,3,4
order by 4 asc, 5 desc
),
max_no as(
	select max(total)as highest,cte.country from cte
	group by cte.country
)
select cte.* from cte
join max_no on cte.country=max_no.country
where cte.total=max_no.highest
order by 4 asc;



















