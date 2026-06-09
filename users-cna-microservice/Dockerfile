FROM python:3.11-slim

RUN pip install --no-cache-dir --timeout 300 --retries 10 pipenv

WORKDIR /usr/src/app

COPY Pipfile ./

RUN pipenv install

COPY . .

EXPOSE 9090

CMD ["pipenv", "run", "python", "app.py"]
