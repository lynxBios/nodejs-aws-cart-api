create extension if not exists "uuid-ossp";

CREATE TABLE users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  password TEXT NOT NULL
);

CREATE TABLE carts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NULL,
  status VARCHAR(10) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'ORDERED'))
);

CREATE TABLE cart_items (
	id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
	cart_id uuid NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
	product_id uuid NOT null REFERENCES products(id) ON DELETE NO ACTION,
	count INTEGER
);

CREATE TABLE orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE NO ACTION,
  cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE NO ACTION,
  payment JSON,
  delivery JSON,
  comments TEXT,
  status VARCHAR(10) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'APPROVED', 'CONFIRMED', 'SENT', 'COMPLETED', 'CANCELLED')),
  total  INTEGER NOT NULL
);


INSERT INTO users (name, email, password)
VALUES
  ('User One', 'userone@test.com', 'password1'),
  ('User Two', 'usertwo@test.com', 'password2'),
  ('User Three', 'userthree@test.com', 'password3'),
  ('User Four', 'userfour@test.com', 'password4');


INSERT INTO carts (user_id, status)
SELECT
  users.id,
  CASE WHEN random() < 0.5 THEN 'OPEN' ELSE 'ORDERED' END
FROM users;


INSERT INTO cart_items (cart_id, product_id, count)
SELECT
  carts.id AS cart_id,
  uuid_generate_v4() AS product_id,
  floor(random() * 3 + 1) AS count
FROM carts
JOIN users ON carts.user_id = users.id;


INSERT INTO orders (user_id, cart_id, payment, delivery, comments, status, total)
SELECT
  users.id AS user_id,
  carts.id AS cart_id,
  '{"method": "credit_card", "amount": 100}'::jsonb AS payment,
  '{"address": "123 Main St", "city": "Cityville", "zipcode": "12345"}'::jsonb AS delivery,
  'Test order comments' AS comments,
  CASE WHEN random() < 0.8 THEN 'PAYED' ELSE 'OPEN' END AS status,
  floor(random() * 300 + 100) AS total
FROM carts
JOIN users ON carts.user_id = users.id;
