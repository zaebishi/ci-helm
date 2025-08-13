# Helm Charts Collection

Репозиторий содержит коллекцию типовых Helm чартов для развертывания различных приложений в Kubernetes.

## Доступные чарты

- **[minimal](./minimal/)** - Минималистичный универсальный чарт с поддержкой PostgreSQL и переменных окружения

## Использование

```bash
# Установка чарта
helm install my-app ./minimal/

# Установка с кастомными значениями
helm install my-app ./minimal/ -f my-values.yaml

# Обновление релиза
helm upgrade my-app ./minimal/ -f my-values.yaml

# Удаление релиза
helm uninstall my-app
```

## Требования

- Kubernetes 1.19+
- Helm 3.0+

Подробная документация по каждому чарту находится в соответствующей папке.
