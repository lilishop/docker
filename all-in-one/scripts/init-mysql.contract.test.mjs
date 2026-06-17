import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const script = readFileSync(new URL('./init-mysql.sh', import.meta.url), 'utf8');

test('init-mysql resets the default store member password from runtime env', () => {
  assert.match(script, /make_bcrypt_md5_hash LILI_STORE_PASSWORD "111111"/);
  assert.match(script, /UPDATE li_member[\s\S]*SET username='\$\{store_username\}', mobile='\$\{store_username\}', password='\$\{store_password_hash_sql\}'/);
  assert.match(script, /WHERE id = 1376417684140326912/);
});
