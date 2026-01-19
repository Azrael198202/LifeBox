import os
import asyncpg
from typing import Optional

_pool: Optional[asyncpg.Pool] = None

async def init_db() -> None:
    global _pool
    if _pool is not None:
        return
    dsn = os.environ["DATABASE_URL"]  # 例: postgresql://user:pass@host:5432/db
    _pool = await asyncpg.create_pool(dsn, min_size=1, max_size=10)

async def close_db() -> None:
    global _pool
    if _pool is not None:
        await _pool.close()
        _pool = None

def get_pool() -> asyncpg.Pool:
    if _pool is None:
        raise RuntimeError("DB pool is not initialized. Call init_db() on startup.")
    return _pool
