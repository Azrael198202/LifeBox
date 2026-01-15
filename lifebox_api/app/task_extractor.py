from __future__ import annotations

import json
import re
from typing import Any, Dict, List, Optional


# -----------------------------
# Prompts
# -----------------------------

SYSTEM_PROMPT = r"""
You are a strict task extractor.
Convert messy message text (email/SMS/notification/OCR/ASR) into ONE actionable task record.

OUTPUT RULES:
- Output ONLY one raw JSON object.
- No markdown, no code fences, no comments, no explanations.
- JSON MUST be directly parseable.
- Do NOT wrap JSON in strings. Do NOT escape quotes.
- Do NOT output extra fields.

Return an object matching this schema exactly:
{
  "title": string,
  "source": string or null,
  "assignee": string or null,
  "due_at": string or null,
  "amount": number or null,
  "currency": "JPY"|"CNY"|"USD"|null,
  "phones": string[],
  "urls": string[],
  "risk": "high"|"mid"|"low",
  "status": "pending"|"done",
  "suggested_actions": ("calendar"|"reply"|"open_link")[],
  "confidence": number,
  "notes": string
}

Hard rules:
- NEVER return an all-empty record if text has readable characters.
- title MUST be meaningful if text readable.
- notes MUST include an exact snippet copied from the text if text readable.
- due_at: If any date expression exists, copy it EXACTLY as it appears (do NOT normalize; do NOT add year).
- amount: must be numeric only. Convert "3万円" -> 30000, "1,200円" -> 1200.
- currency ONLY if explicitly indicated by symbols/words (円/¥/JPY, $/USD, 元/人民币/RMB/CNY).
"""


def build_user_prompt(text: str, locale: str, source_hint: Optional[str], now: Optional[str]) -> str:
    return f"""INPUT
Locale: {locale}
SourceHint: {source_hint}
Now: {now}

TEXT_START
{text}
TEXT_END

Return ONLY one JSON object matching the schema exactly.
- title must not be empty if TEXT_START..TEXT_END contains any readable text
- notes must copy an exact snippet from TEXT_START..TEXT_END
"""


# -----------------------------
# Domain keyword packs
# -----------------------------

HIGH_RISK_WORDS = [
    "至急", "緊急", "重要", "本日中", "今日中",
    "停止", "凍結", "ロック", "利用停止", "口座凍結",
    "延滞", "滞納", "督促", "差押", "法的", "訴訟",
    "不正利用", "不審", "セキュリティ", "本人確認が必要",
    "キャンセル料", "違約金",
    "urgent", "immediately", "suspend", "frozen", "locked", "overdue", "penalty",
]

MID_RISK_WORDS = [
    "期限", "締切", "まで", "支払い", "請求", "引落", "引き落とし",
    "予約", "来院", "面談", "提出", "更新", "手続き",
    "due", "deadline", "payment", "bill", "appointment", "submit", "renew",
]

REPLY_HINTS = [
    "返信", "返事", "ご回答", "回答", "連絡", "ご連絡", "提出", "送付",
    "電話", "お電話", "連絡してください", "知らせて", "確認してください",
    "call", "reply", "respond", "RSVP", "confirm", "submit",
]

SCHOOL_HINTS = [
    "学校", "園", "保育園", "幼稚園", "小学校", "中学校", "高校",
    "保護者", "PTA", "参観", "面談", "懇談", "行事", "運動会", "遠足",
    "持ち物", "提出", "配布", "プリント",
]

APPOINTMENT_HINTS = [
    "予約", "来院", "受付", "診察", "受診", "通院",
    "美容院", "サロン", "ネイル", "歯科", "クリニック",
    "チェックイン", "ご来店", "集合",
    "予約変更", "変更", "キャンセル",
]

PAYMENT_HINTS = [
    "支払い", "お支払い", "請求", "引落", "引き落とし", "クレジット", "カード",
    "口座", "残高", "振込", "振り込み", "入金", "出金", "銀行",
    "税", "保険料",
]

WORK_HINTS = [
    "会議", "打ち合わせ", "ミーティング", "面談", "提出", "承認", "確認",
    "依頼", "対応", "作業", "タスク", "資料",
    "meeting", "review", "approve", "action required",
]

CURRENCY_SIGNS = {
    "JPY": ["円", "¥", "JPY"],
    "USD": ["$", "USD"],
    "CNY": ["元", "人民币", "RMB", "CNY"],
}


# -----------------------------
# Regex extraction (fast + stable)
# -----------------------------

URL_RE = re.compile(r"https?://[^\s)>\]]+")
PHONE_RE = re.compile(r"(?:\+?\d{1,3}[- ]?)?(?:\d{2,4}[- ]?\d{2,4}[- ]?\d{3,4})")

# ✅ IMPORTANT: support fullwidth digits and fullwidth slash "／"
# Also remove \b boundary which can fail with Japanese/Unicode OCR.
DATE_PATTERNS = [
    # YYYY/MM/DD or YYYY-MM-DD (half/fullwidth digits, / or ／)
    r"(?:[0-9０-９]{4})[\/／-](?:[0-9０-９]{1,2})[\/／-](?:[0-9０-９]{1,2})",

    # M/D, M/Dまで (half/fullwidth digits, / or ／)
    r"(?:[0-9０-９]{1,2})[\/／-](?:[0-9０-９]{1,2})(?:まで|迄)?",

    # 1月20日 (usually halfwidth digits)
    r"(?:\d{1,2})月(?:\d{1,2})日(?:まで|迄)?",

    # 20日まで (day only; weak but keep)
    r"(?:\d{1,2})日(?:まで|迄)?",

    # Relative
    r"明後日",
    r"明日",
    r"今日",
    r"来週[月火水木金土日]曜",
    r"今週[月火水木金土日]曜",
]

TIME_PATTERNS = [
    r"\b\d{1,2}:\d{2}\b",
    r"\b\d{1,2}時(?:\d{1,2}分)?\b",
    r"\b午前\d{1,2}時(?:\d{1,2}分)?\b",
    r"\b午後\d{1,2}時(?:\d{1,2}分)?\b",
]


def _dedupe(items: List[str]) -> List[str]:
    return list(dict.fromkeys([i for i in items if i is not None]))


def extract_urls(text: str) -> List[str]:
    if not text:
        return []
    return _dedupe(URL_RE.findall(text))


def extract_phones(text: str) -> List[str]:
    if not text:
        return []
    candidates = [c.strip() for c in PHONE_RE.findall(text)]
    cleaned: List[str] = []
    for c in candidates:
        digits = re.sub(r"\D", "", c)
        if len(digits) >= 10:
            cleaned.append(c)
    return _dedupe(cleaned)


def detect_currency(text: str) -> Optional[str]:
    if not text:
        return None
    for code, signs in CURRENCY_SIGNS.items():
        if any(sig in text for sig in signs):
            return code
    return None


def parse_amount(text: str) -> Optional[float]:
    """
    Convert:
      "3万円" => 30000
      "3万" => 30000
      "1,200円" => 1200
      "¥1,200" => 1200
      "$120" => 120
    """
    if not text:
        return None

    m = re.search(r"(\d+(?:\.\d+)?)\s*万\s*円", text)
    if m:
        return float(m.group(1)) * 10000

    m = re.search(r"(\d+(?:\.\d+)?)\s*万\b", text)
    if m:
        return float(m.group(1)) * 10000

    m = re.search(r"(\d{1,3}(?:,\d{3})+|\d+)\s*円", text)
    if m:
        return float(m.group(1).replace(",", ""))

    m = re.search(r"¥\s*(\d{1,3}(?:,\d{3})+|\d+)", text)
    if m:
        return float(m.group(1).replace(",", ""))

    m = re.search(r"\$\s*(\d+(?:\.\d+)?)", text)
    if m:
        return float(m.group(1))

    m = re.search(r"\bUSD\s*(\d+(?:\.\d+)?)\b", text, re.IGNORECASE)
    if m:
        return float(m.group(1))

    return None


def extract_date_candidates(text: str) -> List[str]:
    if not text:
        return []
    found: List[str] = []
    for pat in DATE_PATTERNS:
        for m in re.finditer(pat, text):
            found.append(m.group(0))
    return _dedupe(found)


def extract_time_candidates(text: str) -> List[str]:
    if not text:
        return []
    found: List[str] = []
    for pat in TIME_PATTERNS:
        for m in re.finditer(pat, text):
            found.append(m.group(0))
    return _dedupe(found)


# -----------------------------
# Choosing the single best task (multi-task messages)
# -----------------------------

def _score_date_candidate(text: str, cand: str) -> int:
    score = 0
    window = 40
    idx = text.find(cand)
    near = text[max(0, idx - window): idx + len(cand) + window] if idx != -1 else text

    # deadline signals
    if any(k in near for k in ["期限", "締切", "due", "支払い期限"]):
        score += 10

    if any(k in near for k in ["まで", "迄", "支払い", "提出", "予約", "来院", "引落", "請求"]):
        score += 5

    if cand.endswith(("まで", "迄")):
        score += 3

    if cand in ("今日", "本日", "今日中"):
        score += 6
    elif cand == "明日":
        score += 5
    elif cand == "明後日":
        score += 4

    if "来週" in cand or "今週" in cand:
        score += 2

    if re.match(r"(?:[0-9０-９]{4})[\/／-](?:[0-9０-９]{1,2})[\/／-](?:[0-9０-９]{1,2})", cand):
        score += 2

    return score


def choose_due_at(text: str) -> Optional[str]:
    cands = extract_date_candidates(text)
    if not cands:
        return None
    scored = sorted(((_score_date_candidate(text, c), c) for c in cands), key=lambda x: x[0], reverse=True)
    return scored[0][1]


# -----------------------------
# Title generation (more actionable + domain aware)
# -----------------------------

def _contains_any(text: str, words: List[str]) -> bool:
    t = text.lower()
    return any(w.lower() in t for w in words)


def infer_title(text: str, due_at: Optional[str], amount: Optional[float], currency: Optional[str]) -> str:
    if not text or not text.strip():
        return "内容確認が必要"

    t = text.strip()
    is_payment = _contains_any(t, PAYMENT_HINTS)
    is_appointment = _contains_any(t, APPOINTMENT_HINTS)
    is_school = _contains_any(t, SCHOOL_HINTS)
    is_work = _contains_any(t, WORK_HINTS)

    if is_payment:
        if due_at:
            return "支払い期限を確認して支払う"
        return "支払いを行う"

    if is_appointment:
        if due_at and extract_time_candidates(t):
            return "予約日時を確認して予定に行く"
        if due_at:
            return "予約日を確認して予定に行く"
        return "予約内容を確認する"

    if is_school:
        if "提出" in t:
            return "学校提出物を準備して提出する"
        if "持ち物" in t:
            return "学校の持ち物を準備する"
        if due_at:
            return "学校行事・期限を確認して対応する"
        return "学校連絡を確認して対応する"

    if is_work:
        if "提出" in t:
            return "資料を準備して提出する"
        if _contains_any(t, REPLY_HINTS):
            return "内容を確認して返信する"
        if due_at:
            return "期限を確認して対応する"
        return "依頼内容を確認して対応する"

    if "提出" in t:
        return "提出する"
    if _contains_any(t, REPLY_HINTS):
        return "内容を確認して返信する"
    if due_at:
        return "期限を確認して対応する"
    return "内容を確認して対応する"


# -----------------------------
# Risk / suggested actions / notes
# -----------------------------

def infer_risk(text: str, due_at: Optional[str]) -> str:
    if not text or not text.strip():
        return "low"
    t = text.lower()

    if any(w.lower() in t for w in HIGH_RISK_WORDS):
        return "high"

    if due_at in ("今日", "本日", "今日中"):
        return "high"
    if due_at == "明日":
        return "mid"

    if any(w.lower() in t for w in MID_RISK_WORDS):
        return "mid"

    return "low"


def infer_suggested_actions(text: str, due_at: Optional[str], urls: List[str]) -> List[str]:
    actions: List[str] = []
    if due_at:
        actions.append("calendar")
    if urls:
        actions.append("open_link")
    if text and _contains_any(text, REPLY_HINTS):
        actions.append("reply")
    out: List[str] = []
    for a in actions:
        if a not in out:
            out.append(a)
    return out


def short_evidence(text: str, min_len: int = 10) -> str:
    if not text or not text.strip():
        return "unreadable or empty text"
    s = re.sub(r"\s+", " ", text).strip()
    if len(s) <= 120:
        return s
    keys = ["期限", "締切", "支払い", "請求", "引落", "予約", "来院", "提出", "持ち物", "会議", "面談", "更新"]
    for k in keys:
        idx = s.find(k)
        if idx != -1:
            start = max(0, idx - 20)
            end = min(len(s), idx + 80)
            snippet = s[start:end].strip()
            if len(snippet) >= min_len:
                return snippet
    return s[:120]


# -----------------------------
# Model output parsing + coercion
# -----------------------------

def extract_json_object(raw: str) -> Optional[Dict[str, Any]]:
    if not raw or not isinstance(raw, str):
        return None
    raw = raw.strip()

    try:
        obj = json.loads(raw)
        if isinstance(obj, dict):
            return obj
    except Exception:
        pass

    start = raw.find("{")
    end = raw.rfind("}")
    if start != -1 and end != -1 and end > start:
        chunk = raw[start:end + 1]
        try:
            obj = json.loads(chunk)
            if isinstance(obj, dict):
                return obj
        except Exception:
            return None
    return None


def _coerce_source(parsed_source: Any, source_hint: Optional[str]) -> Optional[str]:
    if isinstance(parsed_source, str) and parsed_source.strip():
        return parsed_source.strip()
    if isinstance(parsed_source, list):
        s = " ".join(str(x) for x in parsed_source if x is not None).strip()
        if s:
            if len(s) > 80:
                return None
            return s
    if source_hint:
        return source_hint
    return None


def _coerce_assignee(v: Any) -> Optional[str]:
    if isinstance(v, str) and v.strip():
        return v.strip()
    return None


def _coerce_status(v: Any) -> str:
    return v if v in ("pending", "done") else "pending"


def _coerce_risk(v: Any, fallback: str) -> str:
    return v if v in ("high", "mid", "low") else fallback


def _coerce_actions(v: Any, fallback: List[str]) -> List[str]:
    allowed = {"calendar", "reply", "open_link"}
    if isinstance(v, list):
        out: List[str] = []
        for x in v:
            if x in allowed and x not in out:
                out.append(x)
        return out or fallback
    return fallback


def _coerce_confidence(v: Any, fallback: float) -> float:
    try:
        f = float(v)
    except Exception:
        f = fallback
    if f < 0:
        f = 0.0
    if f > 1:
        f = 1.0
    return f


def normalize_to_schema(
    *,
    model_output_text: str,
    input_text: str,
    source_hint: Optional[str],
    locale: str,
) -> Dict[str, Any]:
    parsed = extract_json_object(model_output_text) or {}

    text = input_text or ""
    readable = bool(text.strip())

    urls = extract_urls(text)
    phones = extract_phones(text)

    due_at = choose_due_at(text)

    # ✅ Fallback: if due_at not found in raw text, try notes/title from model output
    # (notes/title are supposed to be copied from original text, so still safe)
    if due_at is None:
        cand_sources: List[str] = []
        v_notes = parsed.get("notes")
        v_title = parsed.get("title")
        if isinstance(v_notes, str) and v_notes.strip():
            cand_sources.append(v_notes)
        if isinstance(v_title, str) and v_title.strip():
            cand_sources.append(v_title)

        for s in cand_sources:
            c2 = choose_due_at(s)
            if c2:
                due_at = c2
                break

    currency = detect_currency(text)
    amount = parse_amount(text)

    if amount is not None and currency is None:
        currency = None

    title = parsed.get("title")
    if not isinstance(title, str) or not title.strip():
        title = infer_title(text, due_at, amount, currency)

    notes = parsed.get("notes")
    if not isinstance(notes, str) or not notes.strip():
        notes = short_evidence(text)

    source = _coerce_source(parsed.get("source"), source_hint)
    if source and len(source) > 50 and source_hint:
        source = source_hint

    assignee = _coerce_assignee(parsed.get("assignee"))

    risk_fallback = "mid"
    if readable:
        # reuse inference
        risk_fallback = infer_risk(text, due_at)
    risk = _coerce_risk(parsed.get("risk"), risk_fallback)

    status = _coerce_status(parsed.get("status"))

    suggested_fallback = infer_suggested_actions(text, due_at, urls)
    suggested_actions = _coerce_actions(parsed.get("suggested_actions"), suggested_fallback)

    # confidence heuristic
    if readable and due_at and (amount is not None):
        conf_fallback = 0.9
    elif readable and due_at:
        conf_fallback = 0.8
    elif readable and _contains_any(text, MID_RISK_WORDS):
        conf_fallback = 0.7
    elif readable:
        conf_fallback = 0.6
    else:
        conf_fallback = 0.2

    confidence = _coerce_confidence(parsed.get("confidence"), conf_fallback)

    if readable:
        if not isinstance(title, str) or not title.strip():
            title = "内容を確認して対応する"
        if not isinstance(notes, str) or not notes.strip():
            notes = short_evidence(text)

    return {
        "title": title,
        "source": source,
        "assignee": assignee,
        "due_at": due_at,
        "amount": float(amount) if amount is not None else None,
        "currency": currency,
        "phones": phones,
        "urls": urls,
        "risk": risk,
        "status": status,
        "suggested_actions": suggested_actions,
        "confidence": confidence,
        "notes": notes,
    }
