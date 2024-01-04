import { Injectable, NotFoundException } from '@nestjs/common';
import { Cart, CartItem  } from '../models';
// import { Carts } from '../entities/Cart';
// import { CartItems } from '../entities/CartItems';
// import { Repository } from 'typeorm';
// import { InjectRepository } from '@nestjs/typeorm';
// import { v4 } from 'uuid';
import { UpdateUserCartDTO } from '../dto/update-user-cart.dto';
import pgClient from '../../db';

@Injectable()
export class CartService {
  private userCarts: Record<string, Cart> = {};

  async findByUserId(userId: string): Promise<Cart> {
    if (!userId) {
      return null;
    }

    const cart = await pgClient('carts').where('user_id', userId).first();

    if (!cart) {
      return null;
    }
    const cartItems = await pgClient('cart_items')
      .select(
        'cart_items.product_id',
        'cart_items.count',
        'products.id',
        'products.title',
        'products.description',
        'products.price',
      )
      .join('products', 'cart_items.product_id', 'products.id')
      .where('cart_items.cart_id', cart.id);
    const productsData = cartItems.map((item) => ({
      product: {
        id: item.product_id,
        title: item.title,
        description: item.description,
        price: item.price,
      },
      count: item.count,
    }));

    cart.items = productsData;

    return cart;
  }

  async createByUserId(userId: string): Promise<Cart> {
    const userCart = {
      user_id: userId,
    };

    return (await pgClient('carts')
      .insert(userCart)
      .returning('*')) as any as Cart;
  }

  async findOrCreateByUserId(userId: string): Promise<Cart> {
    const userCart = await this.findByUserId(userId);

    if (userCart) {
      return userCart;
    }

    const newCartUserId = userId;
    const newUserCart = (await this.createByUserId(newCartUserId))[0];

    newUserCart.items = [];

    return newUserCart;
  }

  async updateByUserId(
    userId: string,
    updateUserCartDTO: UpdateUserCartDTO,
  ): Promise<Cart> {
    const { id, items, ...rest } = (await this.findOrCreateByUserId(
      userId,
    )) as any as Cart;

    if (!id) {
      return null;
    }

    const { product, count } = updateUserCartDTO;

    if (count > 0) {
      await pgClient('cart_items')
        .insert({ product_id: product.id, count, cart_id: id })
        .onConflict(['cart_id', 'product_id'])
        .merge()
        .returning('*');

      const { updatedAt } = await pgClient('carts')
        .select('updated_at')
        .where('id', id)
        .first();
      const updatedCart = {
        id,
        ...rest,
        updatedAt,
        items: [
          updateUserCartDTO,
          ...items.filter((item) => item.product.id !== product.id),
        ],
      };

      return updatedCart;
    }

    await pgClient('cart_items')
      .where({ cart_id: id, product_id: product.id })
      .del();

    const { updatedAt } = await pgClient('carts')
      .select('updated_at')
      .where('id', id)
      .first();
    const updatedCart = {
      id,
      ...rest,
      updatedAt,
      items: [...items.filter((item) => item.product.id !== product.id)],
    };

    return updatedCart;
  }

  async removeByUserId(userId: string): Promise<void> {
    await pgClient.transaction(async (trx) => {
      await trx('carts').where('carts.user_id', userId).del();
    });
  }
}
