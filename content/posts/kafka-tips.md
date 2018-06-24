+++
title = "Kafka tips & tricks"
date = 2018-06-23T18:13:44+03:00
draft = false
tags = ["Kafka"]

+++

{{% img src="media/apache-kafka.png" %}}

---
Список консьюмер-групп
```
docker run wurstmeister/kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka:9092 --list
```

---
Информация по консьюмер-группе
```
docker run wurstmeister/kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka:9092 --group id1 --describe
```

---
Установка оффсета на начало
```
docker run wurstmeister/kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka:9092 --topic topic --group id1 --reset-offsets --to-earliest --execute
```

---
Установка оффсета на конец
```
docker run wurstmeister/kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka:9092 --topic topic --group id1 --reset-offsets --to-latest --execute
```

---
Установка оффсета на дату-время
```
docker run wurstmeister/kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka:9092 --topic topic --group id1 --reset-offsets --to-datetime "2017-12-22T00:00:00.000" --execute
```

---
Установка оффсета на дату-время для партишенов 0, 1 (одно время для всех партишенов)
```
docker run wurstmeister/kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka:9092 --topic topic:0,1 --group id1 --reset-offsets --to-datetime "2017-12-22T00:00:00.000" --execute
```

---
Установка оффсета на дату-время для партишенов 0, 1 (разное время для партишенов)
```
docker run dddpaul/kafka-rewind --servers=kafka:9092 --group-id=id1 --topic=topic -o 0=2017-12-01 -o 1=2018-01-01
```

---
Создать топик
```
docker exec -it wurstmeister/kafka sh -c "JMX_PORT=10001 /opt/kafka/bin/kafka-topics.sh --create --topic topic --replication-factor 1 --partitions 1 --zookeeper zookeeper:2181"
```

---
Накидать сообщений
```
docker exec -it wurstmeister/kafka sh -c "JMX_PORT=10001 /opt/kafka/bin/kafka-verifiable-producer.sh --topic topic --max-messages 200000 --broker-list localhost:9092"
```

---
Консольный консьюмер
```
docker exec -it wurstmeister/kafka sh -c "JMX_PORT=10001 /opt/kafka/bin/kafka-console-consumer.sh --topic topic --bootstrap-server host:9092"
docker run -it wurstmeister/kafka -c "JMX_PORT=10001 /opt/kafka/bin/kafka-console-consumer.sh --topic topic --bootstrap-server host:9092"
docker run --entrypoint=/opt/kafka/bin/kafka-console-consumer.sh wurstmeister/kafka --topic topic --bootstrap-server host:9092
```

---
Python консьюмер
```
#!/usr/bin/env python
from kafka import KafkaConsumer
consumer = KafkaConsumer(bootstrap_servers='kafka1:9092',
                         group_id=None,
                         auto_offset_reset='earliest')
consumer.subscribe(['rsyslog_apps'])
for msg in consumer:
    print msg
```

---
Kafkacat консьюмер
```
docker run -it confluentinc/cp-kafkacat kafkacat -b host:9092 -t topic -o beginning -v
```

---
Установка retention на топик
```
docker exec -it kafka /opt/kafka/bin/kafka-configs.sh --zookeeper host:2181 --entity-type topics --entity-name topic --describe
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --zookeeper host:2181 --topic topic --describe
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --zookeeper host:2181 --topic topic --alter --config retention.ms=1000
```
