FROM python:3.8-slim-buster

WORKDIR /app

RUN pip3 install pytest pytest-selenium

COPY pytest.ini pytest.ini
COPY page_test.py page_test.py

CMD pytest -v \
    --base-url=$BASE_URL \
    --driver=Remote \
    --selenium-host=$SELENIUM_HOST \
    --selenium-port=$SELENIUM_PORT \
    --capability browserName chrome
