# Получение токена Yandex Audience API

## Шаг 1: Зарегистрируйте приложение

1. Перейдите на https://oauth.yandex.ru/client/new
2. Укажите название приложения
3. В разделе «Платформы» выберите «Веб-сервисы»
4. В «Права» добавьте:
   - **Яндекс.Аудитории** → Создание и изменение параметров своих и доверенных сегментов
   - **Яндекс.Аудитории** → Чтение параметров настройки своих и доверенных сегментов
5. Сохраните `client_id`

## Шаг 2: Получите OAuth токен

Откройте в браузере:

```
https://oauth.yandex.ru/authorize?response_type=token&client_id=ВАШ_CLIENT_ID
```

После авторизации токен будет в URL:
```
https://oauth.yandex.ru/#access_token=ВАШТОКЕН&token_type=bearer&expires_in=31536000
```

## Шаг 3: Настройте токен

```bash
cp config/.env.example config/.env
```

Вставьте токен:
```
YANDEX_AUDIENCE_TOKEN=ваш_токен_здесь
```

## Проверка

```bash
bash scripts/check_connection.sh
```

## Частые проблемы

### "Unauthorized" (401)
- Токен устарел → получите новый
- Нет прав на Яндекс.Аудитории → пересоздайте приложение с нужными правами

### "Too Many Requests" (429)
- Превышен лимит запросов → подождите (IP: 30 req/sec, user: 5000 req/day)
- Разблокировка по IP — в течение секунды, по user_login — в полночь по МСК

## Срок жизни токена

Токен действует **1 год**. После истечения получите новый.

## Документация

- Audience API: https://yandex.ru/dev/audience/ru/
- OAuth: https://yandex.ru/dev/oauth/doc/dg/concepts/about.html
