import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_panel/models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    final orderModel = context.read<OrderModel>();
    await orderModel.fetchOrders('new');
    await orderModel.fetchOrders('active');
    await orderModel.fetchOrders('completed');
  }


  @override
  Widget build(BuildContext context) {
    final orderModel = context.watch<OrderModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Управление заказами")),
      body: Row(
        children: [
          // ===== Боковая панель со списком заказов =====
          Expanded(
            flex: 2,
            child: ListView(
              children: [
                _buildSection(
                  context,
                  "🟠 Новые заказы",
                  orderModel.orders.where((o) => o.status == OrderStatus.pending).toList(),
                ),
                _buildSection(
                  context,
                  "🔵 Активные",
                  orderModel.orders
                      .where(
                        (o) => o.status == OrderStatus.transit || o.status == OrderStatus.delivered,
                      )
                      .toList(),
                ),
                _buildSection(
                  context,
                  "✅ Завершенные",
                  orderModel.orders
                      .where(
                        (o) =>
                            o.status == OrderStatus.completed || o.status == OrderStatus.cancelled,
                      )
                      .toList(),
                ),
              ],
            ),
          ),

          // ===== Панель деталей =====
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[100],
              child: orderModel.selectedOrder == null
                  ? const Center(child: Text("Выберите заказ"))
                  : const OrderDetailsPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Order> orders) {
    final orderModel = context.read<OrderModel>();

    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: orders.isEmpty
          ? [const ListTile(title: Text("Нет заказов"))]
          : orders.map((order) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text("Заказ ${order.createdAt}"),
                  subtitle: Text("Статус: ${order.status.name}"),
                  trailing: Text("${order.totalPrice} ₽"),
                  selected: orderModel.selectedOrder?.id == order.id,
                  selectedTileColor: const Color.fromARGB(68, 33, 149, 243),
                  onTap: () => orderModel.selectOrder(order),
                ),
              );
            }).toList(),
    );
  }
}

// ===== Панель с деталями =====
class OrderDetailsPanel extends StatelessWidget {
  const OrderDetailsPanel({super.key});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.transit:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Новый";
      case OrderStatus.transit:
        return "В пути";
      case OrderStatus.delivered:
        return "Доставлен";
      case OrderStatus.completed:
        return "Завершен";
      case OrderStatus.cancelled:
        return "Отменен";
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderModel = context.watch<OrderModel>();
    final order = orderModel.selectedOrder!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== Заголовок =====
        Card(
          color: _statusColor(order.status).withOpacity(0.1),
          child: ListTile(
            title: Text("Заказ ${order.createdAt}"),
            subtitle: Text("Статус: ${order.status.name}"),
            trailing: Text(
              "${order.totalPrice} ₽",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ===== Кнопка смены статуса =====
        // ===== Выпадающий список для смены статуса =====
        Row(
          children: [
            const Text(
              "Изменить статус:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            DropdownButton<OrderStatus>(
              value: order.status,
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              items: OrderStatus.values.map((status) {
                return DropdownMenuItem<OrderStatus>(
                  value: status,
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: _statusColor(status), size: 14),
                      const SizedBox(width: 6),
                      Text(_statusLabel(status)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newStatus) {
                if (newStatus != null) {
                  order.status = newStatus;
                  orderModel.selectOrder(order);


                  orderModel.updateOrder(order);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ===== Список товаров =====
        const Text("Товары:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...order.items.map((item) {
          return Card(
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.image), // TODO: картинка товара
              ),
              title: Text("Товар #${item.productId}"),
              subtitle: Text("Количество: ${item.quantity}"),
              trailing: Text("${item.price} ₽"),
            ),
          );
        }),

        const SizedBox(height: 20),

        // ===== Доставка =====
        const Text("Доставка:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Адрес: ${order.delivery.address}"),
                Text("Координаты: ${order.delivery.latitude}, ${order.delivery.longitude}"),
                Text("Расстояние: ${order.delivery.distanceKm} км"),
                Text("Вес: ${order.delivery.packageWeight} кг"),
                Text("Размер: ${order.delivery.packageSize}"),
                // Text(
                //   "Статус доставки: ${order.delivery.status.name}",
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     color: _statusColor(order.delivery.status.toOrderStatus()),
                //   ),
                // ),
                Text("Назначена: ${order.delivery.scheduledAt}"),
                if (order.delivery.deliveredAt != null)
                  Text("Доставлена: ${order.delivery.deliveredAt}"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===== Конвертация статусов доставки =====
extension on DeliveryStatus {
  OrderStatus toOrderStatus() {
    switch (this) {
      case DeliveryStatus.pending:
        return OrderStatus.pending;
      case DeliveryStatus.transit:
        return OrderStatus.transit;
      case DeliveryStatus.delivered:
        return OrderStatus.delivered;
    }
  }
}
