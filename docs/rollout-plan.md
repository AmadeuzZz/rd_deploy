# Rollout Plan

## Рекомендуемый rollout

```text
1. Тестовая OU
2. 5–10 ПК
3. Один отдел
4. Следующий отдел
5. Весь парк
```

## Без deploy-групп

Можно упростить:

```text
Security Filtering: Domain Computers
WMI filter: делит ОС
Rollout: линковать GPO на OU отделами
```

## С deploy-группами

Более контролируемо:

```text
GG_RustDesk_Win7_Deploy
GG_RustDesk_Win10_11_Deploy
```

GPO применится только если:

```text
ПК в группе + ОС прошла WMI filter
```

## Проверка покрытия

Основной источник истины:

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$\reports
```

Если ПК не появился в reports:

```text
- выключен
- не перезагружался
- не получил GPO
- проблема DNS
- проблема времени
- проблема доступа к шаре
- не прошёл WMI filter
```

## Частота обновления GPO

Обычно:

```text
90 минут + random offset до 30 минут
```

Но Startup Script выполняется при старте ПК, поэтому для немедленного теста нужен reboot.
