from __future__ import annotations

from pydantic import BaseModel,EmailStr
from typing import Optional, List

class EmailRegisterRequest(BaseModel):
    email: EmailStr
    password: str  # 至少 8 位（后端会校验）

class EmailLoginRequest(BaseModel):
    email: EmailStr
    password: str

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
