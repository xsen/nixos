---
name: update-nvidia
description: Автоматическое обновление версии драйвера NVIDIA в конфигурации NixOS с автополучением и прописыванием всех хешей пакетов.
---

# Навык: update-nvidia

Этот навык предназначен для автоматического обновления драйвера NVIDIA до последней стабильной (Production) или экспериментальной (New Feature) версии с официального сайта NVIDIA.

Скилл сам:
1. Проверяет актуальную версию драйвера на официальном сайте NVIDIA Unix Drivers.
2. Сравнивает её с текущей версией в вашем `hosts/nix-desktop/configuration.nix`.
3. Если на сайте вышла новая версия (или запущен принудительно), скачивает и вычисляет (prefetch) хеши для всех 5 необходимых компонентов:
   - x86_64 драйвер
   - aarch64 драйвер
   - open modules
   - nvidia-settings
   - nvidia-persistenced
4. Конвертирует хеши в формат SRI (`sha256-...`) и бесконфликтно прописывает их в `configuration.nix` в блок `mkDriver`.
5. Запускает тестовую сборку (`nix build` всей конфигурации системы без применения), чтобы убедиться в отсутствии синтаксических ошибок или несовместимости версий драйвера с текущим ядром Linux.

## Использование

Для запуска обновления выполните скрипт:

```bash
# Обновление до последней стабильной Production-версии (рекомендуется)
./.agents/skills/update-nvidia/scripts/update-nvidia.py

# Обновление до New Feature ветки (экспериментальные драйвера)
./.agents/skills/update-nvidia/scripts/update-nvidia.py --branch latest

# Принудительное обновление хешей для текущей версии
./.agents/skills/update-nvidia/scripts/update-nvidia.py --force

# Пропустить тестовую сборку
./.agents/skills/update-nvidia/scripts/update-nvidia.py --skip-build
```

После успешного выполнения скрипт предложит применить изменения:
```bash
nh os switch
```
или
```bash
sudo nixos-rebuild switch --flake .#nix-desktop
```
