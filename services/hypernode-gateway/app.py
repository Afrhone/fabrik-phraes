import os, time, yaml
from pathlib import Path
from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Fabrik‑Phraes Hypernode", version="0.1.0")

FABRIK_DIR = Path(os.environ.get("FABRIK_DIR", "/data/fabrik"))
CFG_PATH = Path(os.environ.get("HYPERNODE_CONFIG", FABRIK_DIR / "hypernode.yml"))

def load_yaml(p: Path):
    try:
        with open(p, 'r') as f:
            return yaml.safe_load(f) or {}
    except Exception:
        return {}

@app.get("/api/hypernode/health")
def health():
    return {"ok": True, "time": int(time.time()), "adapter": {"type":"local"}}

@app.get("/api/hypernode/resources")
def resources():
    cfg = load_yaml(CFG_PATH)
    return {
        "name": cfg.get("name","fabrik-phraes"),
        "cluster": cfg.get("cluster","afrhoneth"),
        "env": cfg.get("env","dev"),
        "resources": cfg.get("resources",{}),
        "time": int(time.time())
    }

class HandshakeReq(BaseModel):
    node_id: str
    purpose: Optional[str] = None

@app.post("/api/hypernode/handshake")
def handshake(req: HandshakeReq):
    if not req.node_id:
        raise HTTPException(status_code=400, detail="node_id required")
    token = f"ts:{int(time.time())}:node:{req.node_id}"
    return {"token": token}

