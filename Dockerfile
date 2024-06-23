FROM python:3.11-slim

# Install necessary tools for debugging
RUN apt-get update && apt-get install -y iputils-ping redis-tools

# Create working folder and install dependencies
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN python -m pip install --upgrade pip poetry && \
    poetry config virtualenvs.create false && \
    poetry install --without dev

# Install gunicorn via pip
RUN pip install gunicorn

# Copy the application contents
COPY wsgi.py .
COPY service/ ./service/

# Switch to a non-root user
RUN useradd --uid 1000 flask && chown -R flask /app
USER flask

# Expose any ports the app is expecting in the environment
ENV FLASK_APP=wsgi:app
ENV PORT 8080
EXPOSE $PORT

ENV GUNICORN_BIND 0.0.0.0:$PORT
ENTRYPOINT ["gunicorn"]
CMD ["--log-level=info", "wsgi:app"]
