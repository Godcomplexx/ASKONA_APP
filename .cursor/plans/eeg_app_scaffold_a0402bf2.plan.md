---
name: EEG App Scaffold
overview: "Создание каркаса Flutter приложения для работы с ЭЭГ-гарнитурой: структура папок по Clean Architecture, базовые экраны, навигация, state management на Provider, модели данных и заглушки сервисов."
todos:
  - id: setup-dependencies
    content: Настроить зависимости в pubspec.yaml (provider, go_router, path_provider, shared_preferences)
    status: completed
  - id: create-folder-structure
    content: "Создать структуру папок: core/, data/, domain/, presentation/ с подпапками"
    status: completed
  - id: create-domain-entities
    content: "Создать доменные модели: HeadsetDevice, RecordingSession, RecordingFile, RecordingSettings"
    status: completed
  - id: create-data-models
    content: Создать DTO модели с методами fromJson/toJson и конвертацией в domain entities
    status: completed
  - id: create-repositories
    content: Создать репозитории (HeadsetRepository, RecordingRepository, StorageRepository) с заглушками
    status: completed
  - id: create-services
    content: Создать сервисы (BluetoothService, FileService) с интерфейсами и заглушками
    status: completed
  - id: create-providers
    content: Создать провайдеры состояния (HeadsetProvider, RecordingProvider, StorageProvider)
    status: completed
  - id: setup-theme
    content: Настроить тему приложения и константы
    status: completed
  - id: create-widgets
    content: Создать переиспользуемые виджеты (ConnectionStatusWidget, RecordingStatusWidget, StorageIndicatorWidget)
    status: completed
  - id: create-screens
    content: "Создать все 4 экрана: ConnectionScreen, RecordingScreen, SettingsScreen, FilesScreen"
    status: completed
  - id: setup-navigation
    content: Настроить навигацию с роутингом между экранами
    status: completed
  - id: update-main
    content: "Обновить main.dart: MultiProvider, роутер, тема"
    status: completed
isProject: false
---

# План создания каркаса Android приложения для ЭЭГ-гарнитуры

## Цель

Создать базовую структуру Flutter приложения с архитектурой, готовой для дальнейшей разработки функционала подключения к ЭЭГ-гарнитуре, записи данных и управления файлами.

## Архитектура

Применяется Clean Architecture с разделением на слои:

- **Presentation**: UI, виджеты, провайдеры состояния
- **Domain**: модели данных, интерфейсы use-cases
- **Data**: репозитории, сервисы, источники данных

## Структура проекта

```
app/lib/
├── main.dart                    # Точка входа
├── core/                        # Общие компоненты
│   ├── theme/
│   │   └── app_theme.dart      # Тема приложения
│   ├── constants/
│   │   └── app_constants.dart  # Константы (пути, форматы)
│   └── utils/
│       └── extensions.dart     # Расширения (DateTime, String)
├── data/                        # Слой данных
│   ├── models/                  # Модели данных (DTO)
│   │   ├── headset_device.dart
│   │   ├── recording_session.dart
│   │   ├── recording_file.dart
│   │   └── recording_settings.dart
│   ├── repositories/            # Репозитории (заглушки)
│   │   ├── headset_repository.dart
│   │   ├── recording_repository.dart
│   │   └── storage_repository.dart
│   └── services/                # Сервисы (заглушки)
│       ├── bluetooth_service.dart
│       └── file_service.dart
├── domain/                      # Слой домена
│   └── entities/                # Доменные сущности
│       ├── headset_device.dart
│       ├── recording_session.dart
│       ├── recording_file.dart
│       └── recording_settings.dart
└── presentation/                # Слой представления
    ├── providers/               # State management (Provider)
    │   ├── headset_provider.dart
    │   ├── recording_provider.dart
    │   └── storage_provider.dart
    ├── screens/                 # Экраны
    │   ├── connection/
    │   │   └── connection_screen.dart
    │   ├── recording/
    │   │   └── recording_screen.dart
    │   ├── settings/
    │   │   └── settings_screen.dart
    │   └── files/
    │       └── files_screen.dart
    ├── widgets/                 # Переиспользуемые виджеты
    │   ├── connection_status.dart
    │   ├── recording_status.dart
    │   └── storage_indicator.dart
    └── navigation/
        └── app_router.dart      # Навигация
```

## Задачи реализации

### 1. Настройка зависимостей

**Файл**: `app/pubspec.yaml`

Добавить зависимости:

- `provider: ^6.1.1` - state management
- `go_router: ^14.0.0` или `flutter_navigation` - навигация
- `path_provider: ^2.1.1` - работа с путями файловой системы
- `shared_preferences: ^2.2.2` - локальное хранилище настроек

### 2. Создание доменных моделей

**Файлы**: `app/lib/domain/entities/*.dart`

Создать базовые классы:

- `HeadsetDevice`: id, name, address, rssi, connectionStatus
- `RecordingSession`: id, startTime, endTime, status, files
- `RecordingFile`: path, startTime, endTime, duration, size, isCompleted
- `RecordingSettings`: fileSplitInterval, allowBackgroundRecording, autoStartOnConnect

### 3. Создание моделей данных (DTO)

**Файлы**: `app/lib/data/models/*.dart`

Создать классы для сериализации/десериализации с методами `fromJson`/`toJson` и конвертации в domain entities.

### 4. Создание репозиториев (заглушки)

**Файлы**: `app/lib/data/repositories/*.dart`

Создать интерфейсы и базовые реализации:

- `HeadsetRepository`: методы поиска, подключения, отключения (возвращают заглушки)
- `RecordingRepository`: методы старта/стопа записи, получения сессий (заглушки)
- `StorageRepository`: методы получения списка файлов, размера хранилища (заглушки)

### 5. Создание сервисов (заглушки)

**Файлы**: `app/lib/data/services/*.dart`

Создать базовые классы:

- `BluetoothService`: интерфейс для работы с BLE (пока заглушка)
- `FileService`: интерфейс для работы с файлами (пока заглушка)

### 6. Настройка темы приложения

**Файл**: `app/lib/core/theme/app_theme.dart`

Создать `ThemeData` с цветовой схемой, типографикой, стилями кнопок и карточек.

### 7. Создание констант

**Файл**: `app/lib/core/constants/app_constants.dart`

Определить:

- Путь к директории записей
- Формат именования файлов
- Интервалы разбиения файлов (10/30/60 минут)
- Пороги предупреждений о хранилище

### 8. Создание провайдеров состояния

**Файлы**: `app/lib/presentation/providers/*.dart`

Создать ChangeNotifier провайдеры:

- `HeadsetProvider`: состояние подключения, список устройств, текущее устройство
- `RecordingProvider`: состояние записи, текущая сессия, поток данных (заглушка)
- `StorageProvider`: список файлов, занятое место, свободное место

### 9. Создание экранов

**Файлы**: `app/lib/presentation/screens/*/*.dart`

#### 9.1. Экран подключения (`connection_screen.dart`)

- Заголовок "Подключение устройства"
- Кнопка "Сканировать устройства"
- Список найденных устройств (пока пустой)
- Индикатор статуса подключения
- Кнопка подключения (заглушка)

#### 9.2. Экран записи (`recording_screen.dart`)

- Заголовок "Запись ЭЭГ"
- График сигнала (заглушка - пустой контейнер)
- Кнопка "Начать запись" / "Остановить запись"
- Индикаторы: статус подключения, статус записи, свободное место

#### 9.3. Экран настроек (`settings_screen.dart`)

- Заголовок "Настройки"
- Выбор интервала разбиения файла (радио-кнопки: 10/30/60 минут)
- Переключатель "Разрешить запись в фоне"
- Переключатель "Автозапуск при подключении"

#### 9.4. Экран файлов (`files_screen.dart`)

- Заголовок "Записи"
- Список файлов (пока пустой)
- Для каждого файла: дата, время, длительность, размер
- Кнопки действий: удалить, экспортировать (заглушки)

### 10. Создание переиспользуемых виджетов

**Файлы**: `app/lib/presentation/widgets/*.dart`

- `ConnectionStatusWidget`: индикатор статуса подключения (подключено/подключение/отключено)
- `RecordingStatusWidget`: индикатор статуса записи (идёт/остановлена/ошибка)
- `StorageIndicatorWidget`: прогресс-бар свободного места

### 11. Настройка навигации

**Файл**: `app/lib/presentation/navigation/app_router.dart`

Настроить роутинг с маршрутами:

- `/` - экран подключения (главный)
- `/recording` - экран записи
- `/settings` - экран настроек
- `/files` - экран файлов

**Файл**: `app/lib/main.dart`

Обновить точку входа:

- Обернуть приложение в `MultiProvider` с провайдерами
- Настроить роутер
- Применить тему

### 12. Создание расширений

**Файл**: `app/lib/core/utils/extensions.dart`

Добавить расширения:

- `DateTime.format()` - форматирование даты/времени
- `int.formatBytes()` - форматирование размера файла
- `Duration.format()` - форматирование длительности

## Порядок реализации

1. Настройка зависимостей в `pubspec.yaml`
2. Создание структуры папок
3. Создание доменных моделей и DTO
4. Создание репозиториев и сервисов (заглушки)
5. Создание провайдеров состояния
6. Настройка темы и констант
7. Создание базовых виджетов
8. Создание экранов
9. Настройка навигации
10. Обновление `main.dart`

## Результат

После выполнения плана будет создан каркас приложения с:

- Чёткой архитектурой по слоям
- Базовыми экранами с навигацией
- State management на Provider
- Заглушками для всех сервисов и репозиториев
- Готовностью к добавлению реальной логики работы с BLE, записи и файлами