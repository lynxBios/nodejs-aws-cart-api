create extension if not exists "uuid-ossp";

CREATE TABLE products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  price INTEGER NOT NULL CHECK (price >= 0)
);

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
	cart_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
	product_id uuid NOT null REFERENCES products(id) ON DELETE NO ACTION,
	count INTEGER
);

CREATE TABLE orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
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

INSERT INTO products (id, title, description, price)
VALUES
  ('3e4f08fa-1ee7-416e-85e7-d8a7dc6b6356', 'Some Stuff31', 'Some description Stuff31', 476),
  ('80ac4b13-6b4f-437f-a3dd-5be43ac352a8', 'Some Stuff32', 'Some description Stuff32', 834);  


INSERT INTO carts (user_id, status)
SELECT
  users.id,
  CASE WHEN random() < 0.5 THEN 'OPEN' ELSE 'ORDERED' END
FROM users;


INSERT INTO cart_items (cart_id, product_id, count)
SELECT
  carts.id AS cart_id,
  products.id AS product_id,
  floor(random() * 3 + 1) AS count
FROM carts
JOIN users ON carts.user_id = users.id
JOIN products ON true;


INSERT INTO orders (user_id, cart_id, payment, delivery, comments, status, total)
SELECT
  users.id AS user_id,
  carts.id AS cart_id,
  '{"method": "credit_card", "amount": 100}'::jsonb AS payment,
  '{"address": "123 Main St", "city": "Cityville", "zipcode": "12345"}'::jsonb AS delivery,
  'Test order comments' AS comments,
  CASE WHEN random() < 0.8 THEN 'APPROVED' ELSE 'OPEN' END AS status,
  floor(random() * 300 + 100) AS total
FROM carts
JOIN users ON carts.user_id = users.id;
