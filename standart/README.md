# Standard Helm Chart

Стандартный универсальный Helm чарт для развертывания приложений в Kubernetes с поддержкой PostgreSQL и расширенной настройкой переменных окружения.

## Описание

Этот чарт предназначен для развертывания приложений с расширенной функциональностью:
- Развертывание приложения с настраиваемым количеством реплик
- Поддержка Service для доступа к приложению
- Настройка Ingress для внешнего доступа с поддержкой TLS через cert-manager
- Интеграция с PostgreSQL через зависимость (опционально)
- Гибкая система переменных окружения через envFrom (ConfigMap и Secret)
- Подключение существующих ConfigMaps и Secrets
- Поддержка предустановочных задач через scriptJob (migrations, init scripts)
- Автоматическое отслеживание изменений переменных окружения через checksum annotations
- Поддержка приватных Docker registry через imagePullSecrets

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
| `image.repository` | Docker образ приложения | `""` (заполняется CI) |
| `image.tag` | Тег Docker образа | `""` (заполняется CI) |
| `image.pullPolicy` | Политика загрузки образа | `IfNotPresent` |
| `container.port` | Порт контейнера | `9000` |

### Service

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `service.type` | Тип сервиса | `ClusterIP` |
| `service.port` | Порт сервиса | `9000` |

### Ingress

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `ingress.enabled` | Включить Ingress | `false` |
| `ingress.className` | Ingress Controller класс | `nginx` |
| `ingress.host` | Хост для Ingress | `""` |
| `ingress.proxyBodySize` | Максимальный размер тела запроса | `20m` |
| `ingress.tls.enabled` | Включить TLS | `false` |
| `ingress.tls.clusterIssuer` | ClusterIssuer для cert-manager | `letsencrypt-prod` |
| `ingress.tls.secretName` | Имя Secret для TLS | `""` (автогенерируется) |

### Переменные окружения (envFrom)

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `envFrom.enabled` | Включить envFrom | `false` |
| `envFrom.configMapName` | Имя ConfigMap для переменных | `{release-name}-env` |
| `envFrom.secretName` | Имя Secret для переменных | `{release-name}-secret` |
| `envFrom.publicYaml` | YAML содержимое ConfigMap (через --set-file) | `""` |
| `envFrom.secretYaml` | YAML содержимое Secret (через --set-file) | `""` |

### Подключение существующих ресурсов

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `includeVariables.enabled` | Включить подключение существующих ресурсов | `false` |
| `includeVariables.secrets` | Список существующих Secrets | `[]` |
| `includeVariables.configMaps` | Список существующих ConfigMaps | `[]` |

### Script Job

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `scriptJob.enabled` | Включить предустановочный Job | `false` |
| `scriptJob.command` | Команда для выполнения | `["/bin/sh", "-c", "echo 'Script job completed'"]` |
| `scriptJob.resources` | Ресурсы для Job | См. values.yaml |
| `scriptJob.backoffLimit` | Максимальное количество повторных попыток | `3` |
| `scriptJob.activeDeadlineSeconds` | Максимальное время выполнения (сек) | `600` |

### PostgreSQL

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `postgres.enabled` | Включить PostgreSQL (как зависимость) | `false` |
| `postgres.auth.username` | Имя пользователя БД | `app` |
| `postgres.auth.password` | Пароль пользователя | `app` |
| `postgres.auth.database` | Имя базы данных | `app` |
| `postgres.primary.persistence.enabled` | Включить постоянное хранилище | `true` |
| `postgres.primary.persistence.size` | Размер хранилища | `8Gi` |

### Дополнительные параметры

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `podAnnotations.checksum` | Checksum для отслеживания изменений env | `""` (автозаполняется) |
| `registry.pullSecretName` | Имя Secret для доступа к registry | `gitlab-registry-ro` |
| `resources` | Ограничения ресурсов для pod | `{}` |

## Примеры использования

### Простое веб-приложение

```yaml
# values.yaml
replicaCount: 2

image:
  repository: registry.example.com/myapp
  tag: "v1.0.0"
  pullPolicy: IfNotPresent

container:
  port: 8080

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  className: nginx
  host: myapp.example.com
  proxyBodySize: "20m"
  tls:
    enabled: true
    clusterIssuer: letsencrypt-prod
```

### Приложение с PostgreSQL и envFrom

```yaml
# values.yaml
replicaCount: 2

image:
  repository: registry.example.com/myapp
  tag: "v1.0.0"

container:
  port: 9000

service:
  port: 9000

envFrom:
  enabled: true
  # Значения передаются через --set-file при установке:
  # helm install my-app . --set-file envFrom.publicYaml=env.yaml --set-file envFrom.secretYaml=secrets.yaml

postgres:
  enabled: true
  auth:
    username: app
    password: "secure-password"
    database: myappdb
  primary:
    persistence:
      enabled: true
      size: 10Gi

scriptJob:
  enabled: true
  command:
    - "/bin/sh"
    - "-c"
    - "python manage.py migrate"
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

### Пример файла env.yaml (для --set-file envFrom.publicYaml)

```yaml
NODE_ENV: production
API_URL: https://api.example.com
DEBUG: "false"
LOG_LEVEL: info
```

### Пример файла secrets.yaml (для --set-file envFrom.secretYaml)

```yaml
DATABASE_URL: postgresql://app:password@postgres-service:5432/myappdb
JWT_SECRET: your-secret-key-here
API_KEY: your-api-key-here
```

### С подключением существующих Secrets и ConfigMaps

```yaml
# values.yaml
image:
  repository: registry.example.com/myapp
  tag: "v1.0.0"

includeVariables:
  enabled: true
  secrets:
    - shared-secrets
    - postgres-credentials
  configMaps:
    - shared-config
    - app-config
```

### Установка с envFrom через файлы

```bash
# Создайте файлы с переменными окружения
cat > env.yaml <<EOF
NODE_ENV: production
API_URL: https://api.example.com
EOF

cat > secrets.yaml <<EOF
DATABASE_URL: postgresql://...
JWT_SECRET: secret-value
EOF

# Установка с переменными окружения
helm install my-app . \
  --set image.repository=registry.example.com/myapp \
  --set image.tag=v1.0.0 \
  --set envFrom.enabled=true \
  --set-file envFrom.publicYaml=env.yaml \
  --set-file envFrom.secretYaml=secrets.yaml \
  --set ingress.enabled=true \
  --set ingress.host=myapp.example.com \
  --set ingress.tls.enabled=true
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

## Особенности

### Автоматическое отслеживание изменений переменных окружения

Чарт автоматически отслеживает изменения в переменных окружения через checksum аннотации в podAnnotations. При изменении ConfigMap или Secret, поды автоматически перезапускаются.

### ScriptJob для миграций и предустановочных задач

ScriptJob выполняется перед установкой/обновлением через Helm hooks и предназначен для:
- Выполнения миграций базы данных
- Инициализационных скриптов
- Предварительной настройки приложения

Job автоматически удаляется после успешного выполнения благодаря `hook-delete-policy`.

### Поддержка приватных Docker registry

Чарт автоматически добавляет imagePullSecrets для доступа к приватным реестрам Docker (например, GitLab Registry). По умолчанию используется `gitlab-registry-ro`.

## Требования

- Kubernetes 1.19+
- Helm 3.0+
- При использовании Ingress: установленный Ingress Controller (nginx)
- При использовании TLS: установленный cert-manager с настроенным ClusterIssuer
- При использовании PostgreSQL: зависимость postgresql устанавливается автоматически при `postgres.enabled=true`
- Доступ к приватному Docker registry (если используется): создан Secret для imagePullSecrets

## Поддержка

Для вопросов и предложений создавайте issues в репозитории.