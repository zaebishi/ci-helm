# Minimal Helm Chart

Минималистичный универсальный Helm чарт для развертывания приложений в Kubernetes с поддержкой PostgreSQL и гибкой настройкой переменных окружения.

## Описание

Этот чарт предназначен для быстрого развертывания простых приложений с базовой функциональностью:
- Развертывание приложения с настраиваемым количеством реплик
- Поддержка Service для доступа к приложению
- Настройка Ingress для внешнего доступа
- Интеграция с PostgreSQL (опционально)
- Гибкая система переменных окружения
- Поддержка volumes и secrets

## Установка

```bash
# Базовая установка
helm install my-app .

# Установка с кастомными значениями
helm install my-app . -f values.yaml

# Установка с переопределением значений через командную строку
helm install my-app . \
  --set image.repository=my-app \
  --set image.tag=latest \
  --set service.port=8080
```

## Конфигурация

### Основные параметры

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `replicaCount` | Количество реплик приложения | `1` |
| `image.repository` | Docker образ приложения | `""` |
| `image.tag` | Тег Docker образа | `""` |
| `image.pullPolicy` | Политика загрузки образа | `IfNotPresent` |
| `nameOverride` | Переопределение имени чарта | `""` |
| `fullnameOverride` | Полное переопределение имени | `""` |

### Service

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `service.type` | Тип сервиса | `ClusterIP` |
| `service.port` | Порт сервиса | `80` |
| `service.targetPort` | Целевой порт контейнера | `8080` |

### Ingress

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `ingress.enabled` | Включить Ingress | `false` |
| `ingress.className` | Ingress Controller класс | `""` |
| `ingress.annotations` | Аннотации для Ingress | `{}` |
| `ingress.hosts` | Хосты для Ingress | `[]` |
| `ingress.tls` | TLS конфигурация | `[]` |

### PostgreSQL

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `postgresql.enabled` | Включить PostgreSQL | `false` |
| `postgresql.host` | Хост PostgreSQL | `""` |
| `postgresql.port` | Порт PostgreSQL | `5432` |
| `postgresql.database` | Имя базы данных | `""` |
| `postgresql.username` | Имя пользователя | `""` |
| `postgresql.existingSecret` | Существующий secret с паролем | `""` |

## Примеры использования

### Простое веб-приложение

```yaml
# values.yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 80

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Приложение с PostgreSQL

```yaml
# values.yaml
image:
  repository: my-node-app
  tag: "v1.0.0"

service:
  port: 3000
  targetPort: 3000

postgresql:
  enabled: true
  host: postgres-service
  port: 5432
  database: myappdb
  username: appuser
  existingSecret: postgres-credentials

env:
  - name: NODE_ENV
    value: "production"
  - name: PORT
    value: "3000"

secretEnv:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-credentials
        key: password
```

### С кастомными переменными окружения

```yaml
# values.yaml
env:
  - name: API_URL
    value: "https://api.example.com"
  - name: DEBUG
    value: "false"

secretEnv:
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: jwt-secret
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: api-key
```

## Управление релизом

```bash
# Проверка статуса
helm status my-app

# Просмотр истории релизов
helm history my-app

# Обновление релиза
helm upgrade my-app . -f values.yaml

# Откат к предыдущей версии
helm rollback my-app 1

# Удаление релиза
helm uninstall my-app
```

## Отладка

```bash
# Рендер шаблонов без установки
helm template my-app . -f values.yaml

# Проверка корректности чарта
helm lint .

# Dry-run установки
helm install my-app . --dry-run --debug
```

## Требования

- Kubernetes 1.19+
- Helm 3.0+
- При использовании Ingress: установленный Ingress Controller
- При использовании PostgreSQL: доступный PostgreSQL сервер или развернутый через отдельный чарт

## Поддержка

Для вопросов и предложений создавайте issues в репозитории.