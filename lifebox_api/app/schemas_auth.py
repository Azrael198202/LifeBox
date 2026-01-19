from __future__ import annotations

from pydantic import BaseModel
from typing import Optional, List


class GoogleAuthRequest(BaseModel):
    id_token: str


class UserOut(BaseModel):
    id: str
    email: Optional[str] = None
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None


class GroupBrief(BaseModel):
    id: str
    name: str
    group_type: str
    role: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut
    groups: List[GroupBrief]


class MeResponse(AuthResponse):
    pass
