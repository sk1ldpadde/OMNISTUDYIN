
FROM python:3.11

ENV PYTHONUNBUFFERED=1

WORKDIR /app

ADD . /app

COPY ./requirements.txt /app/requirements.txt

RUN apt-get update && \
    apt-get install -y python3-dev default-libmysqlclient-dev && \
    apt-get install -y build-essential && \
    apt-get clean

RUN pip install -r requirements.txt

COPY . /app

RUN python3 manage.py makemigrations
RUN python3 manage.py migrate

# Expose ports (if needed, although the official image already exposes default Neo4j ports)
EXPOSE 7474 7473 7687