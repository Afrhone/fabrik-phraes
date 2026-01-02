import express from 'express';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

dotenv.config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 4000;
const __dirname = path.resolve();
const manifestPath = path.join(__dirname, 'fabrik', 'factory.integration.json');

function readManifest(){
  try { return JSON.parse(fs.readFileSync(manifestPath, 'utf8')); } catch { return { name: 'fabrik', version: '0.0.0' }; }
}

app.get('/api/health', (_req, res) => {
  const pkg = readManifest();
  res.json({ ok: true, name: pkg.name || 'fabrik', version: pkg.version || '0.0.0' });
});

app.get('/api/info', (_req, res) => {
  res.json({ ok: true, manifest: readManifest() });
});

app.listen(PORT, () => {
  console.log(`Fabrik service listening on http://localhost:${PORT}`);
});

