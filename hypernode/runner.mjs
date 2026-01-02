#!/usr/bin/env node
// Fabrik Hypernode runner: generate ID, register, then heartbeat loop
import os from 'os';
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

const BASE = process.env.FACTORY_BASE_URL || 'http://localhost:3101';
const NAME = process.env.HYPERNODE_NAME || 'fabrik-hypernode';
const SEED = process.env.HYPERNODE_SEED || '';
const FIXED_ID = process.env.HYPERNODE_ID || '';
const TRAITS = (()=>{ try{ const s=(process.env.HYPERNODE_TRAITS||'{}'); return JSON.parse(s); }catch{ return {}; } })();
const HEARTBEAT_S = Math.max(5, parseInt(process.env.HEARTBEAT_SECONDS||'30',10));
let TOKEN = process.env.HYPERNODE_TOKEN || '';

const STATE_DIR = path.join(process.cwd(), 'fabrik', 'hypernode');
const STATE_FILE = path.join(STATE_DIR, 'state.json');

function saveState(obj){ try{ fs.mkdirSync(STATE_DIR, { recursive: true }); fs.writeFileSync(STATE_FILE, JSON.stringify(obj, null, 2), 'utf8'); }catch{} }
function loadState(){ try{ return JSON.parse(fs.readFileSync(STATE_FILE,'utf8')); }catch{ return null; } }

function genId(seed){
  const hostMeta = { hostname: os.hostname(), platform: os.platform(), release: os.release(), arch: os.arch() };
  const data = { seed, hostMeta, t: Date.now() };
  const hex = crypto.createHash('sha256').update(JSON.stringify(data)).digest('hex');
  return `hn:${hex}`;
}

function metrics(){
  const load = os.loadavg?.()[0] || 0;
  const total = os.totalmem?.() || 0;
  const free = os.freemem?.() || 0;
  return { load1: Number(load.toFixed(3)), memFree: free, memTotal: total, uptime: os.uptime?.()||0 };
}

async function postJSON(url, body, headers={}){
  const res = await fetch(url, { method:'POST', headers:{'Content-Type':'application/json', ...(headers||{})}, body: JSON.stringify(body) });
  if(!res.ok) throw new Error(`${res.status}`);
  return await res.json();
}

async function handshake(id){
  const base = BASE.replace(/\/$/,'');
  const host = { url: BASE, version: process.version, platform: os.platform() };
  const body = { id, name: NAME, traits: TRAITS, host };
  return await postJSON(`${base}/api/fabrik/hypernode/handshake`, body);
}

async function register(id){
  const host = { url: BASE, version: process.version, platform: os.platform() };
  const body = { id, name: NAME, traits: TRAITS, host };
  const headers = TOKEN? { 'x-hypernode-token': TOKEN }: {};
  return await postJSON(`${BASE.replace(/\/$/,'')}/api/hypergraph/register-node`, { ...body, token: TOKEN||undefined }, headers);
}

async function heartbeat(id){
  const body = { id, metrics: metrics(), token: TOKEN||undefined };
  const headers = TOKEN? { 'x-hypernode-token': TOKEN }: {};
  return await postJSON(`${BASE.replace(/\/$/,'')}/api/hypergraph/heartbeat`, body, headers);
}

async function main(){
  let state = loadState() || {};
  let id = FIXED_ID || state.id || '';
  if(!id){ id = genId(SEED || NAME); saveState({ ...state, id }); }
  console.log(`[hypernode] id: ${id}`);
  try{
    if(!TOKEN){
      const hs = await handshake(id); if(hs?.ok && hs.token){ TOKEN = hs.token; saveState({ ...loadState(), id, token: TOKEN }); console.log('[hypernode] token issued'); }
    }
  }catch(e){ console.warn('[hypernode] handshake failed:', e?.message||e); }
  try{ const r = await register(id); console.log('[hypernode] registered:', r?.ok?'ok':'fail'); }catch(e){ console.warn('[hypernode] register failed:', e?.message||e); }
  // Heartbeat loop
  // eslint-disable-next-line no-constant-condition
  while(true){
    try{ const hb = await heartbeat(id); console.log(`[hypernode] heartbeat ok ts=${hb?.ts}`); }
    catch(e){ console.warn('[hypernode] heartbeat failed:', e?.message||e); }
    await new Promise(r=> setTimeout(r, HEARTBEAT_S*1000));
  }
}

main().catch(e=>{ console.error(e); process.exit(1); });
