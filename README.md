# CppCommon

[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

C++ Common Library содержит переиспользуемые компоненты для обработки ошибок и исключений, работы с файловой системой, строками, памятью, потоками, временем и другими системными возможностями.

[Документация API CppCommon](https://chronoxor.github.io/CppCommon/index.html)

## Возможности

- Кроссплатформенная поддержка Linux, macOS и Windows.
- Обработка исключений и системных ошибок.
- Работа с файловой системой.
- Кодирование строк и форматирование с помощью [{fmt}](https://fmt.dev/).
- CPU, память и переменные окружения.
- Shared memory.
- Stack trace.
- Генерация UUID.
- Потоки и примитивы синхронизации.
- Управление временем.

## Требования

- CMake 3.20 или новее.
- Компилятор с поддержкой C++23.
- Установленная библиотека [fmt](https://github.com/fmtlib/fmt) с CMake package config.
- Linux: development package для libuuid.
- Остальные платформенные библиотеки и заголовки, используемые проектом.

CppCommon не загружает и не собирает сторонние зависимости автоматически. Разработчик самостоятельно устанавливает зависимости и при необходимости указывает нестандартные пути через переменные CMake, например `CMAKE_PREFIX_PATH`, `fmt_DIR`, `CPPCOMMON_UUID_INCLUDE_DIR` и `CPPCOMMON_UUID_LIBRARY`.

## Сборка

### Конфигурация

```shell
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
```

Если зависимости установлены в нестандартном префиксе:

```shell
cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/dependencies
```

Для Windows можно указать каталог package config конкретной библиотеки:

```shell
cmake -S . -B build -Dfmt_DIR="D:/Libraries/fmt/lib/cmake/fmt"
```

### Компиляция

```shell
cmake --build build --config Release
```

### Установка

```shell
cmake --install build --prefix /path/to/install
```

После установки библиотека доступна как CMake package `CppCommon` с target `CppCommon::cppcommon`.

## Дополнительные компоненты

Основная библиотека собирается по умолчанию. Дополнительные компоненты включаются явно:

| Опция | Компонент | Зависимости |
|---|---|---|
| `CPPCOMMON_BUILD_PLUGINS` | Плагины | CppCommon |
| `CPPCOMMON_BUILD_EXAMPLES` | Примеры | CppCommon |
| `CPPCOMMON_BUILD_BENCHMARKS` | Benchmarks | Установленный CppBenchmark |
| `CPPCOMMON_BUILD_TESTS` | Тесты | Установленный Catch2 3 |
| `CPPCOMMON_BUILD_DOCUMENTATION` | Документация | Doxygen |

Например, конфигурация с тестами:

```shell
cmake -S . -B build -DCPPCOMMON_BUILD_TESTS=ON
```

Зависимости дополнительных компонентов не ищутся, если соответствующая опция выключена.
