from __future__ import annotations

from pydantic import BaseModel
from typing import Optional, List


class CreateGroupRequest(BaseModel):
    name: str
    group_type: str = "family"  # family/team/other


class GroupOut(BaseModel):
    id: str
    name: str
    group_type: str
    owner_user_id: Optional[str] = None


class MembershipOut(BaseModel):
    user_id: str
    role: str


class GroupDetail(GroupOut):
    members: List[MembershipOut]


class CreateInviteRequest(BaseModel):
    invitee_email: str
    expires_hours: int = 72


class CreateInviteResponse(BaseModel):
    invite_id: str
    token: str


class AcceptInviteRequest(BaseModel):
    token: str


class AcceptInviteResponse(BaseModel):
    group_id: str
    role: str
