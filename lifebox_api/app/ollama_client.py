import httpx

OLLAMA_URL = "http://localhost:11434/api/chat"

async def ollama_chat(model: str, system: str, user: str):
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "stream": False,
        "options": {"temperature": 0.1, "max_tokens": 1000, "num_predict": 180, "num_ctx": 1024},
    }

    async with httpx.AsyncClient(timeout=60) as client:
        r = await client.post(OLLAMA_URL, json=payload)
        r.raise_for_status()
        data = r.json()

    return data["message"]["content"]
