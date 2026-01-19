from __future__ import annotations

import os
import time
from dataclasses import dataclass
from typing import Any, Optional
from uuid import UUID

import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer


@dataclass(frozen=True)
class CurrentUser:
    user_id: UUID
    email: Optional[str] = None
    display_name: Optional[str] = None


_bearer = HTTPBearer(auto_error=False)


def _jwt_secret() -> str:
    secret = os.getenv("JWT_SECRET")
    if not secret:
        raise RuntimeError("JWT_SECRET is not set")
    return secret


def create_access_token(*, user_id: UUID, email: Optional[str] = None, display_name: Optional[str] = None) -> str:
    expires_minutes = int(os.getenv("JWT_EXPIRES_MINUTES", "10080"))  # default 7 days
    now = int(time.time())
    payload: dict[str, Any] = {
        "sub": str(user_id),
        "iat": now,
        "exp": now + expires_minutes * 60,
    }
    if email:
        payload["email"] = email
    if display_name:
        payload["name"] = display_name
    return jwt.encode(payload, _jwt_secret(), algorithm="HS256")


def decode_access_token(token: str) -> dict[str, Any]:
    try:
        return jwt.decode(token, _jwt_secret(), algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


def get_current_user(
    creds: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
) -> CurrentUser:
    if creds is None or not creds.credentials:
        raise HTTPException(status_code=401, detail="Missing Authorization header")

    payload = decode_access_token(creds.credentials)
    try:
        user_id = UUID(payload["sub"])
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token subject")

    return CurrentUser(
        user_id=user_id,
        email=payload.get("email"),
        display_name=payload.get("name"),
    )
