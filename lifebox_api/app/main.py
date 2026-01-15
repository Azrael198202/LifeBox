import json
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .schemas import AnalyzeRequest, AnalyzeResponse
from .prompts import SYSTEM_PROMPT, build_user_prompt
from .ollama_client import ollama_chat

MODEL = "qwen2.5:7b-instruct"
#MODEL = "qwen2.5:3b-instruct"

app = FastAPI(title="lifebox-ai-api")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    return {"ok": True}

@app.post("/api/ai/analyze", response_model=AnalyzeResponse)
async def analyze(req: AnalyzeRequest):
    user_prompt = build_user_prompt(
        req.text, req.locale, req.source_hint, req.now
    )

    content = await ollama_chat(
        model=MODEL,
        system=SYSTEM_PROMPT,
        user=user_prompt,
    )

    try:
        return AnalyzeResponse.model_validate(json.loads(content))
    except Exception:
        return AnalyzeResponse(
            notes="Model did not return valid JSON",
            raw=content,
        )
