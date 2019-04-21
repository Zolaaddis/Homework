use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name
From actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select  *
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select  last_name, first_name
from actor
where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China'); 

-- 3a. You want to keep a description of each actor. Create a column in the table actor named description and use the data type BLOB
Alter table actor
add column description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
Alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT  last_name, COUNT(last_name) AS count_of_last_name
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT  last_name, COUNT(last_name) AS count_of_last_name
FROM actor
GROUP BY last_name
having count_of_last_name > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
set first_name = 'Harpo'
where first_name = 'Groucho' and last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name = 'Groucho'
where first_name = 'Harpo' and last_name = 'Williams';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
Show CREATE TABLE address;

-- 6.a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address
from staff s 
Join address a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select first_name, last_name, sum(amount)
From staff s
Join payment p ON s.staff_id = p.staff_id
where payment_date between '2005-08-01' and '2005-08-31'
Group by first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title, count(actor_id) as 'Number of Actors'
from film f
Join film_actor fa on f.film_id = fa.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(inventory_id) as 'Total Copy'
from film f
Join inventory i on f.film_id = i.film_id
where title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select first_name, last_name, sum(amount) as 'Total Amount Paid'
from customer c
join payment p on c.customer_id = p.customer_id
Group by first_name, last_name
order by last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title 
from film
where title like 'K%' Or title like 'Q%'
     and language_id in 
     (select language_id
	  from language
      where name = 'English');
      
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id in
( 
  select actor_id
  from film_actor
  where film_id in 
(
   select film_id
   from film
   where title = 'Alone Trip'));
  
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email
from customer cus
join address a on a.address_id = cus.address_id
join city c on a.city_id = c.city_id
join country ctry ON c.country_id = ctry.country_id
where country = 'Canada';

-- 7d. Identify all movies categorized as family films.
  select title
  from film f
  join film_category fc on fc.film_id = f.film_id
  join category ca on ca.category_id = fc.category_id
  where name = 'Family';
  
 -- 7e. Display the most frequently rented movies in descending order.
 select title, count(r.inventory_id) Total_Rented
 from Inventory i
 join rental r ON i.inventory_id = r.inventory_id
 join film f on i.film_id = f.film_id
 group by title
 order by Total_Rented desc;
 
 -- 7f. Write a query to display how much business, in dollars, each store brought in.
 select s.store_id, sum(amount) as 'Total Amounts'
 from payment p
 join rental r on r.rental_id = p.rental_id
 join inventory i on i.inventory_id = r.inventory_id
 join  store s on s.store_id = i.store_id
 group by s.store_id;
 -- b
 select s.store_id, sum(amount) as 'Total Amounts'
 from payment p
 join customer cus on cus.customer_id = p.customer_id
 join store s on cus.store_id = s.store_id
 group by s.store_id;
 
 -- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, ctry.country
FROM store s
JOIN address a on s.address_id = a.address_id
JOIN city c on a.city_id = c.city_id
JOIN country ctry on c.country_id = ctry.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT ca.name, sum(p.amount)
FROM rental r
join payment p on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film_category fc on i.film_id = fc.film_id
join category ca on fc.category_id = ca.category_id
group by ca.name
order by sum(p.amount) desc
Limit 5;

-- 8a. Use the solution from the problem above to create a view.
create view top_five_genres as 
   (SELECT ca.name, sum(p.amount)
FROM rental r
join payment p on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film_category fc on i.film_id = fc.film_id
join category ca on fc.category_id = ca.category_id
group by ca.name
order by sum(p.amount) desc
Limit 5);

-- 8b. How would you display the view that you created in 8a?
select *
from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop view top_five_genres;