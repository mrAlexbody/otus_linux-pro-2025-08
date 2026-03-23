FROM python:3.10-slim
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV APP_ROOT /src
ENV CONFIG_ROOT /config

RUN mkdir ${CONFIG_ROOT}
COPY requirements.txt ${CONFIG_ROOT}/
COPY wheels/ ${CONFIG_ROOT}/wheels/

RUN pip install --no-cache-dir \
    --no-index \
    --find-links=${CONFIG_ROOT}/wheels/ \
    -r ${CONFIG_ROOT}/requirements.txt

RUN mkdir ${APP_ROOT}
WORKDIR ${APP_ROOT}
ADD . ${APP_ROOT}
EXPOSE 8000