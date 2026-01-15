from __future__ import annotations

from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional

from .ollama_client import ollama_chat
from .task_extractor import SYSTEM_PROMPT, build_user_prompt, normalize_to_schema


app = FastAPI()


class AnalyzeRequest(BaseModel):
    text: str
    locale: str = "ja-JP"
    source_hint: Optional[str] = None
    now: Optional[str] = None
    model: str = "qwen2.5:3b-instruct"


@app.get("/health")
async def health():
    return {"ok": True}


@app.post("/api/ai/analyze")
async def analyze(req: AnalyzeRequest):
    user_prompt = build_user_prompt(
        text=req.text,
        locale=req.locale,
        source_hint=req.source_hint,
        now=req.now,
    )

    raw = await ollama_chat(
        model=req.model,
        system=SYSTEM_PROMPT,
        user=user_prompt,
    )

    result = normalize_to_schema(
        model_output_text=raw,
        input_text=req.text,
        source_hint=req.source_hint,
        locale=req.locale,
    )
    return result
