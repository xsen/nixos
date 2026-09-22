const { List, ActionPanel, Action, Icon, Color } = require("@vicinae/api");
const React = require("react");
const { useState, useMemo } = React;

const KEYBIND_DATA = [
  // ==========================================
  // GHOSTTY TERMINAL
  // ==========================================
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Alt + W",
    description: "Закрыть активный сплит (как в Zed терминале)",
    keywords: ["ghostty", "сплит", "split", "close", "закрыть", "поверхность", "surface"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> C  (или Ctrl+C)",
    description: "Закрыть активный сплит в стиле Vim (close_surface)",
    keywords: ["ghostty", "vim", "сплит", "split", "close", "закрыть"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> Q  (или Ctrl+Q)",
    description: "Закрыть сплит / выход (quit)",
    keywords: ["ghostty", "vim", "сплит", "split", "quit", "закрыть"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> D  (или Ctrl+D)",
    description: "Закрыть сплит в стиле Zed (space w d)",
    keywords: ["ghostty", "zed", "сплит", "split", "delete", "закрыть"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> H / J / K / L",
    description: "Навигация между сплитами: Влево / Вниз / Вверх / Вправо",
    keywords: ["ghostty", "vim", "навигация", "фокус", "перемещение", "сплит", "split", "focus", "goto"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Alt + Shift + H / J / K / L",
    description: "Быстрая навигация между сплитами (без лидера)",
    keywords: ["ghostty", "быстро", "навигация", "сплит", "split", "focus", "goto"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> V  (или Alt+Shift+V)",
    description: "Вертикальный сплит вправо (new_split:right)",
    keywords: ["ghostty", "сплит", "split", "вертикальный", "vertical", "right", "новый"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> S  (или Alt+Shift+S)",
    description: "Горизонтальный сплит вниз (new_split:down)",
    keywords: ["ghostty", "сплит", "split", "горизонтальный", "horizontal", "down", "новый"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> M  (или Ctrl+Shift+Enter)",
    description: "Переключить зум активного сплита (максимизация)",
    keywords: ["ghostty", "zoom", "зум", "максимизация", "развернуть", "сплит", "split"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> =",
    description: "Выровнять размеры всех сплитов (equalize_splits)",
    keywords: ["ghostty", "equalize", "выровнять", "сплит", "split", "размер"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + W -> Ctrl + W",
    description: "Отправить Ctrl+W в шелл (удаление слова / backward-kill-word)",
    keywords: ["ghostty", "shell", "шелла", "слово", "стереть", "delete", "word"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Сплиты (Splits)",
    key: "Ctrl + Shift + Alt + H / J / K / L",
    description: "Изменение размера сплита (на 20px)",
    keywords: ["ghostty", "resize", "размер", "сплит", "split"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Вкладки (Tabs)",
    key: "Alt + N",
    description: "Создать новую вкладку (new_tab)",
    keywords: ["ghostty", "tab", "вкладка", "новая", "таб"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Вкладки (Tabs)",
    key: "Alt + Shift + W",
    description: "Закрыть всю вкладку со всеми сплитами (close_tab)",
    keywords: ["ghostty", "tab", "вкладка", "закрыть", "таб"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Вкладки (Tabs)",
    key: "Alt + H  /  Alt + L",
    description: "Предыдущая / Следующая вкладка",
    keywords: ["ghostty", "tab", "вкладка", "переключение", "next", "prev", "таб"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Вкладки (Tabs)",
    key: "Alt + 1 .. 8",
    description: "Перейти к вкладке по номеру (1-8)",
    keywords: ["ghostty", "tab", "вкладка", "номер", "таб"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Вкладки (Tabs)",
    key: "Alt + 9",
    description: "Перейти к последней вкладке",
    keywords: ["ghostty", "tab", "вкладка", "последняя", "last", "таб"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Система и Буфер",
    key: "Ctrl + Shift + P",
    description: "Палитра команд Ghostty (Command Palette)",
    keywords: ["ghostty", "command", "palette", "палитра", "команды"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Система и Буфер",
    key: "Ctrl + Shift + ,",
    description: "Перезагрузить конфигурацию Ghostty (reload_config)",
    keywords: ["ghostty", "config", "конфиг", "перезагрузить", "reload"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Система и Буфер",
    key: "Ctrl + ,",
    description: "Открыть файл конфигурации Ghostty",
    keywords: ["ghostty", "config", "конфиг", "открыть", "open"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Система и Буфер",
    key: "Ctrl + Shift + C  /  V",
    description: "Копировать в буфер / Вставить из буфера",
    keywords: ["ghostty", "copy", "paste", "буфер", "копировать", "вставить"],
  },
  {
    app: "Ghostty",
    appColor: Color.Purple,
    category: "Система и Буфер",
    key: "Ctrl + Enter",
    description: "Полноэкранный режим терминала",
    keywords: ["ghostty", "fullscreen", "полный экран"],
  },

  // ==========================================
  // ZED EDITOR
  // ==========================================
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Сплиты и Окна (Panes)",
    key: "Ctrl + H / J / K / L",
    description: "Перемещение между сплитами (Влево / Вниз / Вверх / Вправо)",
    keywords: ["zed", "навигация", "фокус", "сплит", "pane", "split", "focus"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Сплиты и Окна (Panes)",
    key: "Space + W + V",
    description: "Вертикальный сплит вправо (pane::SplitRight)",
    keywords: ["zed", "сплит", "split", "vertical", "вертикальный"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Сплиты и Окна (Panes)",
    key: "Space + W + H",
    description: "Горизонтальный сплит вниз (pane::SplitDown)",
    keywords: ["zed", "сплит", "split", "horizontal", "горизонтальный"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Сплиты и Окна (Panes)",
    key: "Space + W + M",
    description: "Максимизация / Зум сплита (workspace::ToggleZoom)",
    keywords: ["zed", "zoom", "зум", "максимизация", "полный экран"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Сплиты и Окна (Panes)",
    key: "Space + W + D",
    description: "Закрыть активный сплит / файл (Normal Mode)",
    keywords: ["zed", "close", "закрыть", "файл", "сплит", "pane"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Сплиты и Окна (Panes)",
    key: "Space + W + O",
    description: "Закрыть все остальные сплиты и файлы (CloseOtherItems)",
    keywords: ["zed", "close", "закрыть", "остальные", "other"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Сплиты и Окна (Panes)",
    key: "Space + W + B",
    description: "Переключатель табов / буферов (tab_switcher)",
    keywords: ["zed", "tab", "switcher", "табы", "буферы"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Вкладки и Терминал",
    key: "Alt + W",
    description: "Закрыть активный элемент терминала (CloseActiveItem)",
    keywords: ["zed", "terminal", "терминал", "закрыть", "close"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Вкладки и Терминал",
    key: "Alt + T",
    description: "Открыть / скрыть встроенную панель терминала",
    keywords: ["zed", "terminal", "терминал", "открыть", "toggle"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Вкладки и Терминал",
    key: "Alt + N",
    description: "Новый терминал в панели терминалов",
    keywords: ["zed", "terminal", "терминал", "новый", "new"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Вкладки и Терминал",
    key: "Alt + H  /  Alt + L",
    description: "Предыдущая / Следующая вкладка (или терминал)",
    keywords: ["zed", "tab", "вкладка", "переключение", "next", "prev"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Вкладки и Терминал",
    key: "Space + 1 .. 9",
    description: "Перейти к вкладке 1-9 в активном сплите (Normal Mode)",
    keywords: ["zed", "tab", "вкладка", "номер"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Вкладки и Терминал",
    key: "Alt + 1 .. 4",
    description: "Перейти к терминалу 1-4 в панели терминалов",
    keywords: ["zed", "terminal", "терминал", "номер"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Боковые панели (Panels)",
    key: "Space + A",
    description: "Открыть / скрыть ИИ-ассистента (Agent Panel)",
    keywords: ["zed", "agent", "ai", "ии", "ассистент", "чат"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Боковые панели (Panels)",
    key: "Space + F",
    description: "Дерево файлов проекта (Project Panel)",
    keywords: ["zed", "files", "файлы", "проект", "дерево"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Боковые панели (Panels)",
    key: "Space + G",
    description: "Панель Git изменений (Git Panel)",
    keywords: ["zed", "git", "панель", "дифф", "diff"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Боковые панели (Panels)",
    key: "Space + O",
    description: "Панель структуры / аутлайн файла (Outline Panel)",
    keywords: ["zed", "outline", "структура", "символы", "функции"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Боковые панели (Panels)",
    key: "Space + S",
    description: "Поиск символов в проекте (Project Symbols)",
    keywords: ["zed", "symbols", "символы", "функции", "поиск"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Боковые панели (Panels)",
    key: "Space + P",
    description: "Открыть недавний проект (Open Recent)",
    keywords: ["zed", "recent", "недавние", "проекты"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Поиск и Vim навигация",
    key: "Shift + Shift",
    description: "Быстрый поиск файла в проекте (File Finder)",
    keywords: ["zed", "find", "file", "поиск", "файл", "быстро"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Поиск и Vim навигация",
    key: "Space + Space",
    description: "Helix прыжок к слову (HelixJumpToWord)",
    keywords: ["zed", "helix", "jump", "прыжок", "слово", "переход"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Поиск и Vim навигация",
    key: "Space + /",
    description: "Глобальный текстовый поиск по проекту (Search)",
    keywords: ["zed", "search", "поиск", "grep", "текст"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Поиск и Vim навигация",
    key: "g + R",
    description: "Найти все ссылки на символ под курсором (Find References)",
    keywords: ["zed", "references", "ссылки", "использование", "lsp"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Поиск и Vim навигация",
    key: "s  /  Shift + S",
    description: "Быстрый прыжок Sneak вперед / назад (Vim Mode)",
    keywords: ["zed", "sneak", "прыжок", "поиск", "символ"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Код, LSP и Рефакторинг",
    key: "Space + C + A",
    description: "Меню быстрых исправлений кода (Code Actions / Quick Fix)",
    keywords: ["zed", "actions", "быстрое действие", "исправление", "lsp"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Код, LSP и Рефакторинг",
    key: "Space + C + R",
    description: "Переименовать символ / переменную (Rename)",
    keywords: ["zed", "rename", "переименовать", "рефакторинг"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Код, LSP и Рефакторинг",
    key: "Space + C + F",
    description: "Форматировать весь документ (Format Document)",
    keywords: ["zed", "format", "форматирование", "стиль"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Код, LSP и Рефакторинг",
    key: "Space + C + I",
    description: "Организовать и отсортировать импорты (Organize Imports)",
    keywords: ["zed", "imports", "импорты", "очистить"],
  },
  {
    app: "Zed",
    appColor: Color.Blue,
    category: "Код, LSP и Рефакторинг",
    key: "Space + X + X",
    description: "Панель диагностики и ошибок проекта (Diagnostics)",
    keywords: ["zed", "diagnostics", "ошибки", "проблемы", "errors"],
  },

  // ==========================================
  // HYPRLAND WINDOW MANAGER
  // ==========================================
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Управление окнами",
    key: "Super + Return",
    description: "Запустить терминал (Ghostty)",
    keywords: ["hyprland", "terminal", "терминал", "запуск", "ghostty"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Управление окнами",
    key: "Super + C",
    description: "Закрыть активное окно",
    keywords: ["hyprland", "close", "закрыть", "окно", "kill"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Управление окнами",
    key: "Super + F",
    description: "Переключить плавающий режим окна (Float)",
    keywords: ["hyprland", "float", "плавающее", "окно"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Управление окнами",
    key: "Super + W",
    description: "Переключить ориентацию сплита окна (Toggle Split)",
    keywords: ["hyprland", "split", "сплит", "dwindle", "раскладка"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Управление окнами",
    key: "Super + F11",
    description: "Полноэкранный режим окна (Fullscreen)",
    keywords: ["hyprland", "fullscreen", "полный экран"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Управление окнами",
    key: "Super + M",
    description: "Завершить сессию Hyprland (uwsm stop)",
    keywords: ["hyprland", "exit", "выход", "сессия", "logout"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Навигация (Vim HJKL)",
    key: "Super + H / J / K / L",
    description: "Переместить фокус: Влево / Вниз / Вверх / Вправо",
    keywords: ["hyprland", "focus", "фокус", "навигация", "перемещение", "окно"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Навигация (Vim HJKL)",
    key: "Super + Shift + H / J / K / L",
    description: "Переместить окно: Влево / Вниз / Вверх / Вправо",
    keywords: ["hyprland", "move", "переместить", "окно", "позиция"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Навигация (Vim HJKL)",
    key: "Super + ЛКМ (drag)",
    description: "Перетаскивание окна мышью",
    keywords: ["hyprland", "mouse", "drag", "перетаскивание", "мышь"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Навигация (Vim HJKL)",
    key: "Super + ПКМ (drag)",
    description: "Изменение размера окна мышью",
    keywords: ["hyprland", "mouse", "resize", "размер", "мышь"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Группы окон (Tabs)",
    key: "Super + G",
    description: "Создать / расформировать группу окон (Tabbed group)",
    keywords: ["hyprland", "group", "группа", "табы", "вкладки"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Группы окон (Tabs)",
    key: "Super + N  /  Super + P",
    description: "Следующее / Предыдущее окно в группе",
    keywords: ["hyprland", "group", "группа", "next", "prev", "переключение"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Группы окон (Tabs)",
    key: "Super + Ctrl + H / J / K / L",
    description: "Задвинуть окно внутрь группы с нужной стороны",
    keywords: ["hyprland", "group", "группа", "переместить", "внутрь"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Группы окон (Tabs)",
    key: "Super + Ctrl + G",
    description: "Вытащить окно из группы",
    keywords: ["hyprland", "group", "группа", "извлечь", "вытащить"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Рабочие столы (Workspaces)",
    key: "Super + 1 .. 10",
    description: "Переключиться на рабочий стол 1-10",
    keywords: ["hyprland", "workspace", "воркспейс", "стол", "рабочий"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Рабочие столы (Workspaces)",
    key: "Super + Shift + 1 .. 10",
    description: "Переместить окно на рабочий стол 1-10",
    keywords: ["hyprland", "workspace", "переместить", "стол", "рабочий"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Рабочие столы (Workspaces)",
    key: "Super + Колесико мыши",
    description: "Быстрое перелистывание рабочих столов",
    keywords: ["hyprland", "workspace", "колесико", "перелистывание"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Super + Space",
    description: "Открыть главный лаунчер Vicinae",
    keywords: ["hyprland", "vicinae", "лаунчер", "меню", "запуск", "поиск"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Super + /",
    description: "Быстрый вызов этой шпаргалки хоткеев (Vicinae)",
    keywords: ["hyprland", "cheatsheet", "hotkeys", "шпаргалка", "хоткеи"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Super + Shift + Space",
    description: "Меню приложений Rofi (drun, calc, window)",
    keywords: ["hyprland", "rofi", "лаунчер", "меню"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Print",
    description: "Скриншот выделенной области экрана",
    keywords: ["hyprland", "screenshot", "скриншот", "область", "снимок"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Shift + Print",
    description: "Скриншот активного окна",
    keywords: ["hyprland", "screenshot", "скриншот", "окно", "снимок"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Ctrl + Print",
    description: "Скриншот всего экрана (монитора)",
    keywords: ["hyprland", "screenshot", "скриншот", "экран", "снимок"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Super + O",
    description: "Заблокировать экран (Hyprlock)",
    keywords: ["hyprland", "lock", "блок", "экран", "заблокировать"],
  },
  {
    app: "Hyprland",
    appColor: Color.Green,
    category: "Лаунчеры и Утилиты",
    key: "Super + I",
    description: "Включить / выключить автосон (Hypridle Toggle)",
    keywords: ["hyprland", "idle", "сон", "hypridle", "автосон"],
  },
];

function HotkeysCheatsheet() {
  const [selectedApp, setSelectedApp] = useState("all");

  const filteredItems = useMemo(() => {
    if (selectedApp === "all") return KEYBIND_DATA;
    return KEYBIND_DATA.filter((item) => item.app.toLowerCase() === selectedApp.toLowerCase());
  }, [selectedApp]);

  // Group items by category (or by App when "all" is selected)
  const groupedSections = useMemo(() => {
    const groups = {};
    for (const item of filteredItems) {
      const groupKey = selectedApp === "all" ? item.app : item.category;
      if (!groups[groupKey]) {
        groups[groupKey] = [];
      }
      groups[groupKey].push(item);
    }
    return Object.entries(groups).map(([title, items]) => ({
      title,
      items,
    }));
  }, [filteredItems, selectedApp]);

  return React.createElement(
    List,
    {
      searchBarPlaceholder: "Поиск хоткеев (например: split, закрыть, ctrl+w, zed, zoom)...",
      searchBarAccessory: React.createElement(
        List.Dropdown,
        {
          tooltip: "Фильтр по приложению",
          value: selectedApp,
          onChange: setSelectedApp,
        },
        React.createElement(List.Dropdown.Item, { title: "Все приложения (All)", value: "all" }),
        React.createElement(List.Dropdown.Item, { title: "Ghostty Terminal", value: "ghostty" }),
        React.createElement(List.Dropdown.Item, { title: "Zed Editor", value: "zed" }),
        React.createElement(List.Dropdown.Item, { title: "Hyprland WM", value: "hyprland" })
      ),
    },
    groupedSections.map((section) =>
      React.createElement(
        List.Section,
        {
          key: section.title,
          title: section.title,
          subtitle: `${section.items.length}`,
        },
        section.items.map((item, idx) =>
          React.createElement(List.Item, {
            key: `${item.app}-${item.key}-${idx}`,
            icon: Icon.Keyboard,
            title: item.key,
            subtitle: item.description,
            accessories:
              selectedApp === "all"
                ? [
                    {
                      tag: {
                        value: item.category,
                        color: item.appColor,
                      },
                    },
                  ]
                : [],
            keywords: [item.key, item.description, item.app, item.category, ...(item.keywords || [])],
            actions: React.createElement(
              ActionPanel,
              null,
              React.createElement(Action.CopyToClipboard, {
                title: "Скопировать комбинацию",
                content: item.key,
              }),
              React.createElement(Action.CopyToClipboard, {
                title: "Скопировать описание",
                content: `${item.key}: ${item.description}`,
              })
            ),
          })
        )
      )
    )
  );
}

module.exports = HotkeysCheatsheet;
module.exports.default = HotkeysCheatsheet;
module.exports.__esModule = true;

