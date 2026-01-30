class ErrorHandler {
  static String formatError(dynamic error) {
    if (error == null) {
      return 'Неизвестная ошибка';
    }

    final errorString = error.toString().toLowerCase();

    // Bluetooth errors
    if (errorString.contains('bluetooth') || errorString.contains('ble')) {
      if (errorString.contains('disabled') || errorString.contains('выключен')) {
        return 'Bluetooth выключен. Включите Bluetooth в настройках устройства.';
      }
      if (errorString.contains('permission') || errorString.contains('разрешение')) {
        return 'Необходимо разрешение на использование Bluetooth. Проверьте настройки приложения.';
      }
      if (errorString.contains('not found') || errorString.contains('не найден')) {
        return 'Устройство не найдено. Проверьте, что устройство включено и находится рядом.';
      }
      if (errorString.contains('connect') || errorString.contains('подключ')) {
        return 'Не удалось подключиться к устройству. Проверьте, что устройство включено и доступно.';
      }
      return 'Ошибка Bluetooth: ${error.toString()}';
    }

    // file errors
    if (errorString.contains('file') || errorString.contains('файл')) {
      if (errorString.contains('permission') || errorString.contains('разрешение')) {
        return 'Необходимо разрешение на доступ к файлам. Проверьте настройки приложения.';
      }
      if (errorString.contains('space') || errorString.contains('место')) {
        return 'Недостаточно свободного места на устройстве.';
      }
      return 'Ошибка работы с файлами: ${error.toString()}';
    }

    // network errors
    if (errorString.contains('network') || errorString.contains('сеть')) {
      return 'Ошибка сети. Проверьте подключение к интернету.';
    }

    // common errors
    if (errorString.contains('timeout') || errorString.contains('таймаут')) {
      return 'Превышено время ожидания. Попробуйте еще раз.';
    }

    if (errorString.contains('exception')) {
      // extract message from Exception
      final message = error
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('Exception:', '');
      if (message.isNotEmpty && message != error.toString()) {
        return message;
      }
    }

    // return original message if not able to determine error type
    return error.toString();
  }

  static String formatBluetoothError(dynamic error) {
    final formatted = formatError(error);
    if (formatted.contains('Bluetooth')) {
      return formatted;
    }
    return 'Ошибка Bluetooth: $formatted';
  }

  static String formatFileError(dynamic error) {
    final formatted = formatError(error);
    if (formatted.contains('файл') || formatted.contains('file')) {
      return formatted;
    }
    return 'Ошибка работы с файлами: $formatted';
  }
}
