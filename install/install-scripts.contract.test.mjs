import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const publishedImage = 'ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite';

test('shell installer defaults to the published image and pulls on each run', () => {
  const script = readFileSync(new URL('./install-lilishop.sh', import.meta.url), 'utf8');

  assert.match(script, new RegExp(`DEFAULT_IMAGE="\\$\\{LILISHOP_IMAGE:-${escapeRegExp(publishedImage)}\\}"`));
  assert.match(script, /local force_pull="\$\{LILISHOP_FORCE_PULL:-true\}"/);
});

test('powershell installer defaults to the published image and pulls on each run', () => {
  const script = readFileSync(new URL('./install-lilishop.ps1', import.meta.url), 'utf8');

  assert.match(script, new RegExp(`Env-OrDefault "LILISHOP_IMAGE" "${escapeRegExp(publishedImage)}"`));
  assert.match(script, /Env-OrDefault "LILISHOP_FORCE_PULL" "true"/);
});

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
