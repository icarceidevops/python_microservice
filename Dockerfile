FROM python:3.10-alpine

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache make
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x entrypoint.sh

RUN pip install Sphinx sphinx-autobuild

RUN cd docs && make html

# Expose port 80 for Sphinx documentation and port 8080 for the main application
EXPOSE 80 8080


#CMD ["sh", "-c", "sphinx-autobuild --host 0.0.0.0 --port 80 docs docs/_build/html"]
ENTRYPOINT ["./entrypoint.sh"]
