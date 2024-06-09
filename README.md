# Eureka

## Kubernetes

Для простоти в цій демонстрації я використовую `microk8s` із встановленими аддонами `dns` та `metallb`.

Сервер `microk8s` можна встановити на ОС `Ubuntu` за допомогою наступної команди.
```sh
sudo snap install microk8s --classic --channel=1.30/stable
```

Щоб встановити аддони, які використовуються в цій демонстрації, виконайте наступні команди:
```sh
microk8s enable metallb:192.168.1.201-192.168.1.254

microk8s enable dns
```


## Configuration
Файли конфігурації сервера та клієнта зберігаються у відповідних ресурсах ConfigMap і монтуються в директорію з jar-файлом.

Щоб змінити налаштування клієнта або сервера, відредагуйте відповідні ресурси ConfigMap:
- [client](helm/client/templates/properties-configmap.yaml)
- [сервер](helm/server/templates/properties-configmap.yaml)


## Installation
Kubernetes-ресурси клієнта і сервера описані в хелм чартах, які знаходяться в директорії `helm`.

Щоб встановити клієнт і сервер, необхідно виконати наступні команди:
```sh
helm dependency update ./helm/app
helm dependency build ./helm/app
helm install eureka ./helm/app
```

### Installation demo
Коротка демонстрація того, як встановлюються клієнт і сервер за допомогою `Helm`.
[![asciicast](https://asciinema.org/a/L7KTCs6b8YAa8TyxPWGwdP6TE.svg)](https://asciinema.org/a/L7KTCs6b8YAa8TyxPWGwdP6TE)

Окремо встановлюється [моніторинговий стек](#monitoring)

## UI
Отримати URL веб-інтерфейсів клієнта і сервера можна за допомогою наступних команд.

Для клієнта:
```sh
CLIENT_IP=$(kubectl get svc eureka-client -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "http://${CLIENT_IP}:8761"
```

Для сервера:
```sh
SERVER_IP=$(kubectl get svc eureka-server -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "http://${SERVER_IP}:8761"
```

## CI/CD
У якості CI/CD для запуску тестів, створення образів контейнерів та інших задач використовується GitHub Actions.


## Links to Docker images
Для зберігання образів контейнерів використовується сховище GitHub Container Repository.

Посилання на образи клієнта і сервера:
- [eureka-client](https://github.com/yevgen-grytsay/eureka/pkgs/container/eureka-client)
- [eureka-server](https://github.com/yevgen-grytsay/eureka/pkgs/container/eureka-server)


## Monitoring
Моніторинговий стек включає в себе такі компоненти: `Fluent-bit`, `OpenTelemetry Collector`, `Loki` та `Grafana`. Збираються 1) тільки логи 2) тільки з сервера і клієнта Eureka. З інших подів логи не збираються. Метрики і трейси не збираються.

Щоб встановити моніторинговий стек, виконайте команди:
```sh
cd ./terraform
terraform apply
```

### Схема роботи моніторингового стеку
```mermaid
flowchart LR

Fluent-bit -->|push| c-p3030



collector -->|push logs| Loki-3100

Grafana -..->|query logs| Loki-3100

subgraph Loki
    Loki-3100(:3100)
end

subgraph collector[Otel Collector]
    c-p3030(:3030)
end

subgraph Legend
    direction LR
    start1[ ] --->|push| stop1[ ]
    style start1 height:0px;
    style stop1 height:0px;
    start2[ ] -..->|pull| stop2[ ]
    style start2 height:0px;
    style stop2 height:0px; 
end

style Legend fill:none
```

## Resources
### Spring
- [External Application Properties](https://docs.spring.io/spring-boot/reference/features/external-config.html#features.external-config.files)

- [Spring Boot with Docker](https://spring.io/guides/gs/spring-boot-docker)

- [Spring Cloud Netflix](https://cloud.spring.io/spring-cloud-netflix/reference/html/)

### Other
- [Publishing Docker images](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)

- [docker/metadata-action](https://github.com/marketplace/actions/docker-metadata-action)

- [docker/build-push-action](https://github.com/docker/build-push-action)

- [Populate a Volume with data stored in a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#populate-a-volume-with-data-stored-in-a-configmap)