import knex from 'knex';
import 'dotenv/config';

const { HOST, POSTGRES_PORT, DATABASE_NAME, USER_NAME, PASSWORD } = process.env;
const dbOptions = {
  host: HOST,
  port: Number(POSTGRES_PORT),
  database: DATABASE_NAME,
  user: USER_NAME,
  password: PASSWORD,
};

export default knex({
  client: 'pg',
  connection: dbOptions,
});
