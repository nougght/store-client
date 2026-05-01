# Мобильное приложение (Android/IOS) для онлайн-магазина

_Бэкенд (Golang) - <https://github.com/nougght/store-backend>_

## Технологии

- Flutter для кроссплатформенной разработки (Android и iOS)
- Provider для управления состоянием приложения
- http.dart для взаимодействия с бэкендом
- Yandex MapKit для встроенной карты при выборе адреса доставки

## Функционал

- Регистрация и авторизация пользователей через email(отправка кода по SMTP) и номер(отправка sms не реализована)
- Каталог товаров с возможностью фильтрации и сортировки
- Корзина для добавления товаров и оформления заказа
- Оформление заказа с выбором адреса доставки через встроенную карту (Yandex MapKit)
- Личный профиль пользователя с историей заказов, избранными товарами и настройками

## Админ-панель

Отдельный веб-интерфейс для управления магазином на Flutter Web, позволяет администратору:

- Управлять товарами (создавать, редактировать, удалять)
- Просматривать и обрабатывать заказы (изменять статус, просматривать детали)
- Изменять изображения (загрузка, удаление, замена)
- Управлять категориями товаров

Сборка и запуск админ-панели:

```bash
flutter build web --release
docker-compose -f docker-compose.yml up -d
```
После запуска она будет доступна через порт 8505 (например, <http://localhost:8505>).

## Скриншоты

### Приложение

<a href="https://postimg.cc/876g47pQ" target="_blank"><img src="https://i.postimg.cc/0yt58ShQ/image-2.png" alt="image-2"></a><br><br>
<a href="https://postimg.cc/68vxc891" target="_blank"><img src="https://i.postimg.cc/P56ftD0h/image-1.png" alt="image-1"></a><br><br>
<a href="https://postimg.cc/Wdkc8dNR" target="_blank"><img src="https://i.postimg.cc/Z5fYTNXq/image-3.png" alt="image-3"></a><br><br>
<a href="https://postimg.cc/YvWBRvrw" target="_blank"><img src="https://i.postimg.cc/t4rRX687/image-4.png" alt="image-4"></a><br><br>
<a href="https://postimages.org/" target="_blank"><img src="https://i.postimg.cc/mgdZb9Kk/image-5.png" alt="image-5"></a><br><br>
<a href="https://postimg.cc/21ZNG1kS" target="_blank"><img src="https://i.postimg.cc/8zyk1vxM/image-6.png" alt="image-6"></a><br><br>
<a href="https://postimg.cc/tsxGksqg" target="_blank"><img src="https://i.postimg.cc/dVWQqCgG/image-7.png" alt="image-7"></a><br><br>

### Админ-панель

<a href="https://postimg.cc/0K518Z1b" target="_blank"><img src="https://i.postimg.cc/j2Px4k8Q/image.png" alt="image"></a><br><br>
<a href="https://postimg.cc/zHDYJpYb" target="_blank"><img src="https://i.postimg.cc/fymzfgHK/image-1.png" alt="image-1"></a><br><br>
