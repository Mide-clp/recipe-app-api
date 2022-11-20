FROM python:3.9-alpine3.13
LABEL maintainer="mide"

ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

# Create a new virtual environment to avoid different version of dependenccies
# from the base image, and create a new user to run the docker container commands
RUN python -m venv /env && \ 
    /env/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-dev \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /env/bin/pip install -r /tmp/requirements.txt && \
    if (( "true" == "true" )); then \
        # sleep 40; fi \
        /env/bin/pip install -r /tmp/requirements.dev.txt; fi \
    && \
    rm -rf /tmp && \
    apk del .tmp-build-dev && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/env/bin:$PATH"

USER django-user