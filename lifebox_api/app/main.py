
from __future__ import annotations

from dotenv import load_dotenv
import os

env = os.getenv("ENV", "dev")
load_dotenv(f".env.{env}")


from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional

from .ollama_client import ollama_chat
from .task_extractor import SYSTEM_PROMPT, build_user_prompt, normalize_to_schema

# DB Pool
from .db import init_db, close_db

# routers
from .auth_routes import router as auth_router
from .group_routes import router as group_router
from .cloud_routes import router as cloud_router
from .billing_routes import router as billing_router
from .legal_routes import router as legal_router

app = FastAPI()

# -----------------------------
# App lifecycle: init/close DB
# -----------------------------
@app.on_event("startup")
async def _startup():
    await init_db()


@app.on_event("shutdown")
async def _shutdown():
    await close_db()

# -----------------------------
# Routers
# -----------------------------
app.include_router(auth_router)
app.include_router(group_router)
app.include_router(cloud_router)
app.include_router(billing_router)
app.include_router(cloud_router)
app.include_router(legal_router)

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
