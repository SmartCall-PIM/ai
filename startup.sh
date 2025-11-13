#!/bin/bash

# Instalar dependências
pip install --upgrade pip
pip install -r requirements.txt

# Iniciar a aplicação
python -m uvicorn api.main:app --host 0.0.0.0 --port 8000
