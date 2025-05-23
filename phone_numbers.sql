-- 													Задача 1
-- Аналитик Светлана заметила, что цена на никель, из которого частично сделана пяти центовая монета весом в 5 грамм, которая завалялась в её кармане, выросла. 
-- Никель перевалил за $100к/тонну. В пятицентовой монете 25% никеля (остальное – медь). Вопрос: сколько стоит никель в этой монете?
-- Решение
-- 1)	Посчитаем вес никеля в монете:
-- 5 * 0.25 = 1.25г
-- 2)	Посчитаем цену за один грамм никеля:
-- 100000/1000000 = $0.1/г
-- 3)	Значит никель в этой монете стоит 
-- 1.25*0.1 = $0.125
-- Ответ: $0.125

-- 													MySQL
-- 													Задача 2
CREATE TABLE accounts (
    acc INT PRIMARY KEY,
    name VARCHAR(256),
    email VARCHAR(256),
    phone VARCHAR(256)
);

INSERT INTO accounts(acc, name, email, phone) VALUES
(1, 'Alice', 'alice@example.com', '89151234567'),
(2, 'Bob', 'bob@example.com', '+79167654321'),
(3, 'Charlie', 'ch@example.com', '8(985)123-45-67'),
(4, 'Dylan', 'dylan@example.com', '+79167654321'),
(5, 'Eve', 'eve@example.com', '+79167654321'),
(6, 'Frank', 'frank@example.com', '+79851234567'),
(7, 'Glenda', 'glenda@example.com', '+12124504567');

DROP VIEW IF EXISTS processed_accounts;
CREATE VIEW processed_accounts AS
WITH cte AS (
    SELECT  
        acc, 
        name, 
        email, 
        REGEXP_REPLACE(phone, '[^0-9]', '') AS only_digits 
    FROM accounts
),
cte2 AS (
    SELECT 
        acc, 
        name, 
        email, 
        CASE 
            WHEN (LEFT(only_digits, 1) = '8') THEN CONCAT('7', SUBSTRING(only_digits, 2))
            ELSE only_digits
        END AS only_digits
    FROM cte
)
SELECT 
    acc, 
    name, 
    email, 
    CONCAT('+', only_digits) AS cleaned_phone
FROM cte2;

-- Все номера приведены к одному формату, теперь можно работать

-- С помощью оконной функции найдем пользователей с повторяющимися номерами
WITH ranked_acc AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (PARTITION BY cleaned_phone ORDER BY acc) AS rnk
    FROM processed_accounts
)

SELECT *
FROM ranked_acc
WHERE cleaned_phone IN (
    SELECT DISTINCT cleaned_phone
    FROM ranked_acc
    WHERE rnk > 1 
); -- найдем номера которые дублируются (в таблице оставим ВСЕ дублирующиеся номера (не только те у которых rnk больше 1, так мы увидим всех пользователей с одинаковым номером))

-- Способ номер два (оконная функция)
SELECT *
FROM (
    SELECT 
        *, 
        COUNT(acc) OVER (PARTITION BY cleaned_phone) AS counted -- подсчет количества для каждого номера
    FROM processed_accounts
) oe
WHERE counted > 1; -- выбираем номера с дублирующимися записями

-- Решим задачу без испльзования оконной функции
SELECT *
FROM processed_accounts
WHERE cleaned_phone IN (
    SELECT cleaned_phone
    FROM processed_accounts
    GROUP BY cleaned_phone
    HAVING COUNT(acc) > 1
);
-- Ответ: были найдены 5 аккаунтов с дублирующимися номерами.




