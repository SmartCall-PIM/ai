import os
import uvicorn
import google.generativeai as genai
import json
import configparser
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Optional

# Não usar dotenv no Azure - usar variáveis de ambiente diretas

config = configparser.ConfigParser()
config.read('api/prompts.ini', encoding='utf-8')
PROMPT_TEMPLATE = config['GeminiPrompts']['chamado_ti']

try:
    genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
    model = genai.GenerativeModel('gemini-2.5-flash')
    print("API do Gemini configurada com sucesso!")
except Exception as e:
    print(f"Erro ao configurar a API do Gemini: {e}")
    model = None

class ChamadoBase(BaseModel):
    descricao: str = Field(..., min_length=10)

class AnaliseIA(BaseModel):
    titulo: str
    categoria: str
    prioridade: str
    sugestao_solucao: str 

app = FastAPI(
    title="API de Gestão de Chamados com IA",
    description="Uma API para gerenciar chamados de TI, enriquecidos com análise do Gemini.",
    version="1.0"
)

@app.get("/")
def root():
    """
    Endpoint raiz para verificar se a API está funcionando.
    """
    return {
        "message": "API SmartCall está funcionando!",
        "status": "online",
        "endpoints": {
            "docs": "/docs",
            "redoc": "/redoc",
            "analisar": "/analisar (POST)"
        }
    }

def analisar_chamado_com_gemini(descricao: str) -> Optional[AnaliseIA]:
    """
    Envia a descrição de um chamado para o Gemini e retorna uma análise estruturada.
    """
    if not model:
        return None

    prompt = PROMPT_TEMPLATE.format(descricao=descricao)

    try:
        response = model.generate_content(prompt)
        json_text = response.text.strip().replace("```json", "").replace("```", "")
        dados_ia = json.loads(json_text)
        return AnaliseIA(**dados_ia)

    except Exception as e:
        print(f"Erro ao analisar com o Gemini ou ao processar o JSON: {e}")
        return None

@app.post("/analisar", response_model=AnaliseIA, status_code=200)
def analisar_descricao(entrada: ChamadoBase):
    """
    Recebe uma descrição, analisa com o Gemini e retorna a análise.
    """
    analise = analisar_chamado_com_gemini(entrada.descricao)
    
    if not analise:
        raise HTTPException(status_code=500, detail="Falha ao analisar a descrição com a IA.")
    
    return analise

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)