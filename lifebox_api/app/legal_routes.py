from __future__ import annotations

from datetime import datetime, timezone
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field

router = APIRouter(prefix="/api", tags=["legal"])


# -----------------------------
# Models
# -----------------------------
class LegalResponse(BaseModel):
    type: str = Field(..., pattern=r"^(terms|privacy)$")
    lang: str = Field(..., pattern=r"^(zh|ja|en)$")
    title: str
    html: str
    updated_at: str


# -----------------------------
# HTML contents (ZH/JA/EN)
# 你也可以后续改成从文件读取（S3/DB/本地html）
# -----------------------------
_UPDATED_AT = datetime.now(timezone.utc).isoformat()

_TITLES = {
    "terms": {"zh": "使用条款", "ja": "利用規約", "en": "Terms of Service"},
    "privacy": {"zh": "隐私政策", "ja": "プライバシーポリシー", "en": "Privacy Policy"},
}

# ✅ 简洁版：可直接上线。你要更长更正式我也能给你升级版。
_HTML = {
    "terms": {
        "ja": """
<!doctype html><html><head><meta charset="utf-8"></head><body>
<h1>利用規約</h1>
<p>本利用規約（以下「本規約」）は、本アプリ（以下「本サービス」）の利用条件を定めるものです。ユーザーは、本サービスを利用することにより、本規約に同意したものとみなされます。</p>
<h2>1. 本サービスの内容</h2>
<p>本サービスは、音声・テキスト・画像などの情報をもとに、AIによる分析を行い、タスク管理や予定整理を支援します。</p>
<h2>2. 禁止事項</h2>
<ul>
  <li>法令または公序良俗に違反する行為</li>
  <li>不正な目的で本サービスを利用する行為</li>
  <li>本サービスの運営を妨害する行為</li>
</ul>
<h2>3. 免責</h2>
<ul>
  <li>分析結果や提案の正確性・完全性を保証しません。</li>
  <li>本サービス利用により生じた損害について当方は責任を負いません。</li>
</ul>
<h2>4. 変更・停止</h2>
<p>当方は、事前の通知なく本サービスの内容を変更または停止することがあります。</p>
</body></html>
""",
        "zh": """
<!doctype html><html><head><meta charset="utf-8"></head><body>
<h1>使用条款</h1>
<p>本使用条款用于规定本应用（以下简称“本服务”）的使用条件。用户一旦使用本服务，即视为同意本条款。</p>
<h2>1. 服务内容</h2>
<p>本服务对语音、文本、图片等信息进行 AI 分析，辅助用户完成任务管理与日程整理。</p>
<h2>2. 禁止事项</h2>
<ul>
  <li>违反法律法规或公序良俗的行为</li>
  <li>以不正当目的使用本服务的行为</li>
  <li>妨碍本服务正常运营的行为</li>
</ul>
<h2>3. 免责声明</h2>
<ul>
  <li>不保证分析结果或建议的准确性与完整性。</li>
  <li>因使用本服务产生的任何损失，我们不承担责任。</li>
</ul>
<h2>4. 服务变更与停止</h2>
<p>我们可在无需事先通知的情况下变更或停止本服务。</p>
</body></html>
""",
        "en": """
<!doctype html><html><head><meta charset="utf-8"></head><body>
<h1>Terms of Service</h1>
<p>These Terms govern your use of this app (the “Service”). By using the Service, you agree to these Terms.</p>
<h2>1. About the Service</h2>
<p>The Service helps manage tasks and schedules by analyzing voice, text, and images with AI.</p>
<h2>2. Prohibited Conduct</h2>
<ul>
  <li>Violating laws or regulations</li>
  <li>Using the Service for improper purposes</li>
  <li>Interfering with the operation of the Service</li>
</ul>
<h2>3. Disclaimer</h2>
<ul>
  <li>We do not guarantee accuracy or completeness of results or suggestions.</li>
  <li>We are not liable for damages arising from your use of the Service.</li>
</ul>
<h2>4. Changes</h2>
<p>We may change or suspend the Service without prior notice.</p>
</body></html>
""",
    },
    "privacy": {
        "ja": """
<!doctype html><html><head><meta charset="utf-8"></head><body>
<h1>プライバシーポリシー</h1>
<p>当方は、本サービスにおけるユーザー情報の取扱いについて、以下のとおり定めます。</p>
<h2>1. 取得する情報</h2>
<ul>
  <li>ユーザーが入力または送信した音声、テキスト、画像などの情報</li>
  <li>アプリの利用状況に関する情報</li>
</ul>
<h2>2. 利用目的</h2>
<ul>
  <li>本サービスの提供および改善</li>
  <li>AIによる分析・タスク生成のため</li>
</ul>
<h2>3. 第三者提供</h2>
<p>法令に基づく場合を除き、第三者に提供しません。</p>
<h2>4. 安全管理</h2>
<p>不正アクセスや漏えい防止のため、適切な対策を講じます。</p>
</body></html>
""",
        "zh": """
<!doctype html><html><head><meta charset="utf-8"></head><body>
<h1>隐私政策</h1>
<p>我们重视用户隐私，并就本服务中用户信息的处理规则制定如下政策。</p>
<h2>1. 我们可能收集的信息</h2>
<ul>
  <li>用户输入或发送的语音、文本、图片等信息</li>
  <li>与应用使用相关的信息（例如功能使用情况等）</li>
</ul>
<h2>2. 使用目的</h2>
<ul>
  <li>提供与改进本服务</li>
  <li>用于 AI 分析与生成任务/建议</li>
</ul>
<h2>3. 向第三方提供</h2>
<p>除法律法规要求外，我们不会向第三方提供用户信息。</p>
<h2>4. 信息安全</h2>
<p>我们将采取合理的安全措施，防止信息被未授权访问、泄露或篡改。</p>
</body></html>
""",
        "en": """
<!doctype html><html><head><meta charset="utf-8"></head><body>
<h1>Privacy Policy</h1>
<p>This Policy explains how we handle user information in the Service.</p>
<h2>1. Information We May Collect</h2>
<ul>
  <li>Voice, text, images, and other content you submit</li>
  <li>App usage information (e.g., feature usage)</li>
</ul>
<h2>2. Purposes of Use</h2>
<ul>
  <li>To provide and improve the Service</li>
  <li>To perform AI analysis and generate tasks/suggestions</li>
</ul>
<h2>3. Sharing</h2>
<p>We do not share user information with third parties unless required by law.</p>
<h2>4. Security</h2>
<p>We take reasonable measures to protect data from unauthorized access or leakage.</p>
</body></html>
""",
    },
}


@router.get("/legal", response_model=LegalResponse)
async def get_legal(
    type: str = Query(..., pattern=r"^(terms|privacy)$"),
    lang: str = Query(..., pattern=r"^(zh|ja|en)$"),
):
    t = type.lower().strip()
    l = lang.lower().strip()

    if t not in _HTML or l not in _HTML[t]:
        raise HTTPException(status_code=404, detail="Not found")

    return LegalResponse(
        type=t,
        lang=l,
        title=_TITLES[t][l],
        html=_HTML[t][l],
        updated_at=_UPDATED_AT,
    )