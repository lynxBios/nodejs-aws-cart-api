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
