# Helm Charts Collection

Репозиторий содержит коллекцию типовых Helm чартов для развертывания различных приложений в Kubernetes.

## Доступные чарты

### [minimal](./minimal/)

Минималистичный универсальный Helm чарт для быстрого развертывания простых приложений с базовой функциональностью:

- Развертывание приложения с настраиваемым количеством реплик
- Поддержка Service и Ingress
- Интеграция с PostgreSQL (опционально)
- Гибкая система переменных окружения
- Поддержка миграций базы данных

**Рекомендуется для:** простых приложений с минимальными требованиями к конфигурации.

### [standart](./standart/)

Стандартный универсальный Helm чарт для развертывания приложений с расширенной функциональностью:

- Развертывание приложения с настраиваемым количеством реплик
- Поддержка Service и Ingress с автоматическим TLS через cert-manager
- Интеграция с PostgreSQL через зависимость (опционально)
- Гибкая система переменных окружения через envFrom (ConfigMap и Secret)
- Подключение существующих ConfigMaps и Secrets
- Поддержка предустановочных задач через scriptJob (migrations, init scripts)
- Автоматическое отслеживание изменений переменных окружения через checksum annotations
- Поддержка приватных Docker registry через imagePullSecrets

**Рекомендуется для:** продакшн-приложений с требованиями к безопасности, миграциям и гибкой настройке переменных окружения.

## Быстрый старт

### Установка minimal чарта

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

### Установка standart чарта

```bash
# Установка чарта с переменными окружения
helm install my-app ./standart/ \
  --set image.repository=registry.example.com/myapp \
  --set image.tag=v1.0.0 \
  --set envFrom.enabled=true \
  --set-file envFrom.publicYaml=env.yaml \
  --set-file envFrom.secretYaml=secrets.yaml

# Установка с PostgreSQL и миграциями
helm install my-app ./standart/ \
  --set image.repository=registry.example.com/myapp \
  --set image.tag=v1.0.0 \
  --set postgres.enabled=true \
  --set scriptJob.enabled=true

# Обновление релиза
helm upgrade my-app ./standart/ -f my-values.yaml

# Удаление релиза
helm uninstall my-app
```

## Сравнение чартов

| Функция | minimal | standart |
|---------|---------|----------|
| Базовое развертывание | ✅ | ✅ |
| Service | ✅ | ✅ |
| Ingress | ✅ | ✅ |
| TLS через cert-manager | ❌ | ✅ |
| PostgreSQL (как зависимость) | ❌ | ✅ |
| PostgreSQL (внешний) | ✅ | ✅ |
| Переменные окружения (env) | ✅ | ❌ |
| Переменные окружения (envFrom) | ❌ | ✅ |
| Подключение существующих Secrets/ConfigMaps | ❌ | ✅ |
| Миграции (Job) | ✅ | ✅ |
| ScriptJob через hooks | ❌ | ✅ |
| Автоотслеживание изменений env | ❌ | ✅ |
| imagePullSecrets | ❌ | ✅ |
| Checksum annotations | ❌ | ✅ |

## Выбор чарта

**Используйте `minimal`, если:**
- Вам нужен простой чарт для быстрого старта
- Приложение не требует сложной настройки переменных окружения
- Нет необходимости в автоматическом TLS
- Миграции выполняются через простой Job

**Используйте `standart`, если:**
- Приложение требует гибкой настройки переменных окружения через envFrom
- Нужно автоматическое управление TLS сертификатами через cert-manager
- Требуется интеграция с существующими Secrets и ConfigMaps
- Нужны предустановочные задачи через Helm hooks
- Требуется отслеживание изменений переменных окружения для автоматического перезапуска подов
- Используется приватный Docker registry

## Требования

- Kubernetes 1.19+
- Helm 3.0+

**Дополнительные требования для standart:**
- При использовании Ingress: установленный Ingress Controller (nginx)
- При использовании TLS: установленный cert-manager с настроенным ClusterIssuer
- Доступ к приватному Docker registry (если используется): создан Secret для imagePullSecrets

## Документация

Подробная документация по каждому чарту находится в соответствующей папке:
- [minimal/README.md](./minimal/README.md)
- [standart/README.md](./standart/README.md)

