/ / выводит цены и залы
SELECT
  hall.name_hall,
  repertoire.price
FROM
  hall
  JOIN repertoire ON repertoire.hall = hall.id_hall
GROUP BY
  hall.name_hall,
  repertoire.price;

/ / выводит цены с учетом скидки
SELECT
  DISTINCT hall.id_hall,
  CASE
    WHEN visitors.email <> 'null'
    AND hall.name_hall IN ('IMAX', 'Purple') THEN repertoire.price * 0.5
    ELSE repertoire.price
  END price
FROM
  repertoire
  JOIN hall ON repertoire.hall = hall.id_hall
  JOIN visitors ON visitors.rep = repertoire.id_rep
GROUP BY
  hall.id_hall,
  repertoire.price,
  visitors.email;

/ / сложный запрос 3
SELECT
  list.first_name,
  list.last_name,
  sum(
    repertoire.price * number_of_visitors + list.price * nemail
  ) AS earned
FROM
  (
    SELECT
      vissemail.rep,
      CASE
        WHEN info.hall IN (1, 7) THEN visemail
        ELSE count(info.id_vis)
      END number_of_visitors
    FROM
      (
        SELECT
          visitors.rep,
          count(visitors.id_vis) AS visemail
        FROM
          repertoire
          JOIN visitors ON visitors.rep = repertoire.id_rep
          JOIN hall ON repertoire.hall = hall.id_hall
        WHERE
          visitors.email is null
        GROUP BY
          visitors.rep
      ) vissemail
      JOIN (
        SELECT
          repertoire.hall,
          visitors.email,
          repertoire.id_rep,
          visitors.id_vis
        FROM
          visitors
          JOIN repertoire ON visitors.rep = repertoire.id_rep
      ) info ON vissemail.rep = info.id_rep
    GROUP BY
      visemail,
      vissemail.rep,
      info.hall
    order by
      rep
  ) AS summ
  JOIN (
    SELECT
      employee.first_name,
      employee.last_name,
      discounted.price,
      repertoire.id_rep
    FROM
      repertoire
      JOIN employee ON repertoire.cashier = employee.id_emp
      JOIN (
        SELECT
          DISTINCT hall.id_hall,
          repertoire.price * 0.5 as price
        FROM
          repertoire
          JOIN hall ON repertoire.hall = hall.id_hall
          JOIN visitors ON visitors.rep = repertoire.id_rep
        GROUP BY
          hall.id_hall,
          repertoire.price,
          visitors.email
      ) discounted ON repertoire.hall = discounted.id_hall
  ) list ON summ.rep = list.id_rep
  JOIN (
    SELECT
      visitors.rep,
      CASE
        WHEN hall.id_hall IN (1, 7) THEN count(visitors.id_vis)
        ELSE 0
      END nemail
    FROM
      repertoire
      JOIN visitors ON visitors.rep = repertoire.id_rep
      JOIN hall ON repertoire.hall = hall.id_hall
    WHERE
      visitors.email is not null
    GROUP BY
      visitors.rep,
      hall.id_hall
  ) noemail ON summ.rep = noemail.rep
  JOIN repertoire ON summ.rep = repertoire.id_rep
GROUP BY
  list.first_name,
  list.last_name;

/ / сложный запрос 2
SELECT
  CASE
    WHEN ccase.period_of_time = 1 THEN 'Morning'
    WHEN ccase.period_of_time = 2 THEN 'Day'
    WHEN ccase.period_of_time = 3 THEN 'Evening'
  END time_period,
  sum(pricee * number_of_visitors) AS earned
FROM
  repertoire
  JOIN (
    SELECT
      visitors.rep,
      count(visitors.id_vis) AS number_of_visitors
    FROM
      visitors
    GROUP BY
      visitors.rep
  ) vis ON vis.rep = repertoire.id_rep
  JOIN (
    SELECT
      repertoire.id_rep,
      CASE
        WHEN repertoire.date_time BETWEEN '01/12/2021 09:00'
        AND '01/12/2021 13:20' THEN 1
        WHEN repertoire.date_time BETWEEN '01/12/2021 13:30'
        AND '01/12/2021 18:00' THEN 2
        WHEN repertoire.date_time BETWEEN '01/12/2021 18:30'
        AND '01/12/2021 22:55' THEN 3
      END period_of_time
    FROM
      repertoire
  ) ccase ON ccase.id_rep = repertoire.id_rep
  LEFT JOIN (
    SELECT
      repertoire.id_rep,
      count(repertoire.film)
    FROM
      repertoire
      JOIN films ON repertoire.film = films.id_film
    WHERE
      films.genre LIKE '%comedy%'
    GROUP BY
      repertoire.id_rep
  ) comedy ON comedy.id_rep = repertoire.id_rep
  JOIN (
    SELECT
      repertoire.id_rep,
      CASE
        WHEN films.genre LIKE '%comedy%' THEN repertoire.price * 0.5
        ELSE repertoire.price
      END pricee
    FROM
      repertoire
      JOIN films ON repertoire.film = films.id_film
  ) pricelist ON pricelist.id_rep = repertoire.id_rep
GROUP BY
  ccase.period_of_time
ORDER BY
  ccase.period_of_time;

/ / сложный запрос 1
SELECT
  rephall.name_hall,
  sum(number_of_visitors * rephall.price) AS money
FROM
  (
    SELECT
      visitors.rep,
      count(visitors.id_vis) AS number_of_visitors
    FROM
      repertoire
      LEFT JOIN visitors ON visitors.rep = repertoire.id_rep
    GROUP BY
      visitors.rep
  ) AS summ
  JOIN (
    SELECT
      films.name_film,
      repertoire.price,
      repertoire.id_rep,
      hall.name_hall
    FROM
      repertoire
      JOIN hall ON repertoire.hall = hall.id_hall
      JOIN films ON repertoire.film = films.id_film
  ) AS rephall ON summ.rep = rephall.id_rep
WHERE
  rephall.name_film = 'Encanto '
GROUP BY
  ROLLUP(rephall.name_hall)
ORDER BY
  money DESC;

/ / средний запрос 3
SELECT
  films.name_film,
  repertoire.price,
  films.genre,
  repertoire.date_time
FROM
  repertoire
  JOIN films ON repertoire.film = films.id_film
WHERE
  (
    films.genre LIKE '%horror%'
    OR films.genre LIKE '%thriller%'
  )
  AND (
    repertoire.date_time BETWEEN '01/12/2021 09:00'
    AND '01/12/2021 12:00'
  );

/ / средний запрос 2
SELECT
  employee.first_name,
  employee.last_name,
  post.name_post
FROM
  employee
  JOIN post ON employee.post = post.id_post
WHERE
  employee.sex = 'Male'
  AND EXTRACT(
    YEARS
    FROM
      AGE(employee.date_of_birth)
  ) > 30;

/ / средний запрос 1
SELECT
  hall.name_hall,
  count(visitors.id_vis) as number_of_visitors
FROM
  repertoire
  LEFT JOIN visitors ON visitors.rep = repertoire.id_rep
  JOIN hall ON repertoire.hall = hall.id_hall
GROUP BY
  ROLLUP(hall.name_hall)
ORDER BY
  number_of_visitors DESC;

/ / простой запрос 4
SELECT
  name_film,
  genre,
  rating
FROM
  films
WHERE
  genre LIKE '%comedy%'
ORDER BY
  rating DESC;

/ / простой запрос 3
SELECT
  country,
  count(*)
FROM
  films
GROUP BY
  country
ORDER BY
  count DESC;

/ / простой запрос 2
SELECT
  first_name,
  last_name,
  EXTRACT(
    YEAR
    FROM
      age(date_of_birth)
  ) AS emp_age
FROM
  employee
WHERE
  post = 4
ORDER BY
  last_name,
  first_name;

/ / простой запрос 1
SELECT
  name_film,
  rating
FROM
  films
ORDER BY
  rating DESC
LIMIT
  5;