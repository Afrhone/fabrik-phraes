import 'dotenv/config';
import fetch from 'node-fetch';
import fs from 'fs';
import path from 'path';

const FACTORY_BASE_URL = process.env.FACTORY_BASE_URL;
const FACTORY_TOKEN = process.env.FACTORY_TOKEN;

if (!FACTORY_BASE_URL || !FACTORY_TOKEN) {
  console.error('Missing FACTORY_BASE_URL or FACTORY_TOKEN');
  process.exit(1);
}

const manifestPath = path.join(process.cwd(), 'fabrik', 'factory.integration.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

const url = new URL('/api/factory/register', FACTORY_BASE_URL).toString();
const resp = await fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${FACTORY_TOKEN}` },
  body: JSON.stringify({ manifest })
});
const body = await resp.json().catch(() => ({}));
if (!resp.ok) {
  console.error('Registration failed:', resp.status, body);
  process.exit(2);
}
console.log('Registered with Factory:', body);

