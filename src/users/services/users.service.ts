import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Users } from '../entities/Users';

@Injectable()
export class UsersService {
  // private readonly users: Record<string, User>;

  // constructor() {
  //   this.users = {};
  // }
  constructor(
    @InjectRepository(Users) private usersRepository: Repository<Users>,
  ) {}

  // findOne(userId: string): User {
  //   return this.users[ userId ];
  async findOne(name: string): Promise<Users> {
    return await this.usersRepository.findOne({ where: { name: name } });
  }

  // createOne({ name, password }: User): User {
  //   const id = v4();
  //   const newUser = { id: name || id, name, password };

  //   this.users[ id ] = newUser;

  //   return newUser;
  async createOne({ name, password }: Users): Promise<Users> {
    return await this.usersRepository.save({
      name,
      password,
    });
  }
}
