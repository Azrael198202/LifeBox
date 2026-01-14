from __future__ import annotations
from typing import Optional, List, Literal
from pydantic import BaseModel, Field

Risk = Literal["high", "mid", "low"]
Status = Literal["high", "pending", "done"]

class AnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1)
    locale: str = "ja"
    source_hint: Optional[str] = None
    now: Optional[str] = None

class AnalyzeResponse(BaseModel):
    title: Optional[str] = None
    source: Optional[str] = None
    due_at: Optional[str] = None
    amount: Optional[float] = None
    currency: Optional[str] = None
    phones: List[str] = []
    urls: List[str] = []
    risk: Risk = "mid"
    status: Status = "pending"
    suggested_actions: List[str] = []
    confidence: float = 0.0
    notes: str = ""
    raw: Optional[str] = None
