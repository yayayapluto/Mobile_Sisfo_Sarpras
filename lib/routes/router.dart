import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/new_home_screen.dart';
import '../screens/warehouse/warehouse_list_screen.dart';
import '../screens/category/category_list_screen.dart';
import '../screens/item/item_list_screen.dart';
import '../screens/item/item_detail_screen.dart';
import '../screens/request/request_history_screen.dart';
import '../screens/request/borrow_request_screen.dart';
import '../screens/request/return_request_screen.dart';
import '../screens/request/active_borrows_screen.dart';
import '../screens/profile/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/warehouses',
      name: 'warehouses',
      builder: (context, state) => const WarehouseListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'warehouse-detail',
          builder: (context, state) {
            final warehouseId = state.pathParameters['id']!;
            return ItemListScreen(
              warehouseId: warehouseId,
              title: 'Barang di Gudang',
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoryListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'category-detail',
          builder: (context, state) {
            final categoryId = state.pathParameters['id']!;
            return ItemListScreen(
              categoryId: categoryId,
              title: 'Barang di Kategori',
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/items',
      name: 'items',
      builder: (context, state) => const ItemListScreen(
        title: 'Semua Barang',
      ),
      routes: [
        GoRoute(
          path: ':id',
          name: 'item-detail',
          builder: (context, state) {
            final itemId = state.pathParameters['id']!;
            return ItemDetailScreen(itemId: itemId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/borrow-request',
      name: 'borrow-request',
      builder: (context, state) => const BorrowRequestScreen(),
    ),
    GoRoute(
      path: '/active-borrows',
      name: 'active-borrows',
      builder: (context, state) => const ActiveBorrowsScreen(),
    ),
    GoRoute(
      path: '/return-request/:id',
      name: 'return-request',
      builder: (context, state) {
        final borrowId = int.parse(state.pathParameters['id']!);
        return ReturnRequestScreen(borrowRequestId: borrowId);
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const RequestHistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    )
  ],
);
