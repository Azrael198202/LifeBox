from __future__ import annotations

import httpx
from typing import Any, Dict, Optional


class OllamaError(RuntimeError):
    pass


async def ollama_chat(
    *,
    base_url: str = "http://localhost:11434",
    model: str = "qwen2.5:3b-instruct",
    system: str,
    user: str,
    timeout_s: float = 20.0,
) -> str:
    """
    Calls Ollama /api/chat and returns assistant content as string.
    Raises OllamaError on non-2xx.
    """
    url = f"{base_url.rstrip('/')}/api/chat"
    payload: Dict[str, Any] = {
        "model": model,
        "stream": False,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        # IMPORTANT: options must use Ollama-supported keys (llama.cpp style)
        "options": {
            "temperature": 0.0,
            "top_p": 0.1,
            "num_predict": 220,
            "num_ctx": 512,
            "repeat_penalty": 1.05,
        },
    }

    timeout = httpx.Timeout(timeout_s, connect=3.0)
    async with httpx.AsyncClient(timeout=timeout) as client:
        r = await client.post(url, json=payload)
        if r.status_code // 100 != 2:
            raise OllamaError(f"Ollama HTTP {r.status_code}: {r.text[:500]}")

        data = r.json()
        # Ollama chat response shape: { message: { role, content }, ... }
        msg = (data or {}).get("message") or {}
        content = msg.get("content")
        if not isinstance(content, str):
            raise OllamaError(f"Unexpected Ollama response: {data}")
        return content
