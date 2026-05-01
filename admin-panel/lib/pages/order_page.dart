import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_panel/models/order.dart';
// import 'package:admin_panel/models/order_model.dart';
class OrderPage extends StatelessWidget {
  final Order order;

  const OrderPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderModel = context.read<OrderModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Заказ #${order.id}"),
        actions: [
          PopupMenuButton<OrderStatus>(
            onSelected: (status) {
              order.status = status;
              orderModel.updateOrder(order);
              Navigator.pop(context); // обновит список после возврата
            },
            itemBuilder: (context) => OrderStatus.values.map((status) {
              return PopupMenuItem(value: status, child: Text(status.name));
            }).toList(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOrderInfo(),
          const SizedBox(height: 16),
          _buildItemsList(),
          const SizedBox(height: 16),
          _buildDeliveryInfo(),
        ],
      ),
    );
  }

  /// 🔹 Блок с общей информацией о заказе
  Widget _buildOrderInfo() {
    return Card(
      child: ListTile(
        title: Text("Статус: ${order.status.name}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Создан: ${order.createdAt}"),
            Text("Оплата: ${order.paymentMethod}"),
            Text("Товары: ${order.items.length} шт."),
            Text("Сумма: ${order.totalPrice} ₽"),
            Text("Доставка: ${order.deliveryPrice} ₽"),
          ],
        ),
      ),
    );
  }

  /// 🔹 Список товаров
  Widget _buildItemsList() {
    return Card(
      child: Column(
        children: [
          const ListTile(title: Text("Товары")),
          ...order.items.map((item) {
            return ListTile(
              title: Text("Товар #${item.productId}"),
              subtitle: Text("Количество: ${item.quantity}"),
              trailing: Text("${item.price} ₽"),
            );
          }),
        ],
      ),
    );
  }

  /// 🔹 Информация о доставке
  Widget _buildDeliveryInfo() {
    final d = order.delivery;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(title: Text("Доставка")),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Адрес: ${d.address}"),
                Text("Координаты: ${d.latitude}, ${d.longitude}"),
                Text("Расстояние: ${d.distanceKm} км"),
                Text("Вес: ${d.packageWeight} кг"),
                Text("Размер: ${d.packageSize}"),
                Text("Статус: ${d.status.name}"),
                Text("Назначена: ${d.scheduledAt}"),
                if (d.deliveredAt != null) Text("Доставлена: ${d.deliveredAt}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
