import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Users } from '../entities/Users';
import { v4 } from 'uuid';
import pgClient from '../../db';

@Injectable()
export class UsersService {
  private readonly users: Record<string, User>;

  // constructor() {
  //   this.users = {};
  // }
  // constructor(
  //   @InjectRepository(Users) private usersRepository: Repository<Users>,
  // ) {}
  // findOne(userId: string): User {
  //   return this.users[ userId ];
  async findOne(userName: string): Promise<User> {
    const user = await pgClient('users').where('name', userName).first();
    return user;
  }

  // createOne({ name, password }: User): User {
  async createOne({ name, password }: User): Promise<User> {
      const id = v4();
  //   const newUser = { id: name || id, name, password };
  //   this.users[ id ] = newUser;
  //   return newUser;
      const newUser = (await pgClient('users')
        .insert({ name, password })
        .returning('*')) as any as User;

      return newUser;
    }

}
