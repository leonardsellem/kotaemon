# syntax=docker/dockerfile:1.0.0-experimental
FROM python:3.10-slim as base_image

# for additional file parsers

# tesseract-ocr \
# tesseract-ocr-jpn \
# libsm6 \
# libxext6 \
# ffmpeg \

RUN apt-get update -qqy && \
    apt-get install -y --no-install-recommends \
      ssh \
      git \
      gcc \
      g++ \
      poppler-utils \
      libpoppler-dev \
      curl \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

WORKDIR /app

FROM base_image as dev

COPY . /app
RUN --mount=type=ssh pip install --no-cache-dir -e "libs/kotaemon[all]"
RUN --mount=type=ssh pip install --no-cache-dir -e "libs/ktem"
RUN pip install --no-cache-dir graphrag future
RUN pip install --no-cache-dir "pdfservices-sdk@git+https://github.com/niallcm/pdfservices-python-sdk.git@bump-and-unfreeze-requirements"

EXPOSE 7860

ENTRYPOINT ["gradio", "app.py"]
