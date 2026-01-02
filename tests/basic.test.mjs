import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'fs';

test('manifest exists and is valid JSON', () => {
  const raw = fs.readFileSync('fabrik/factory.integration.json', 'utf8');
  const json = JSON.parse(raw);
  assert.equal(json.name, 'fabrik');
  assert.ok(json.endpoints.health);
});

