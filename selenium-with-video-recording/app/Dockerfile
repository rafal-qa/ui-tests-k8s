FROM python:3.8-slim-buster

WORKDIR /app

RUN pip3 install flask

COPY app.py app.py
COPY templates templates

CMD ["python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=3000"]
