import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const sql = readFileSync(new URL('./mysql/lilishop.sql', import.meta.url), 'utf8');

const previousHashes = {
  admin: '$2a$10$sVnczXsvm2V0SBKCx3e96eRr6Ssl69bh56iD3RJNJE3o2LzqEO4qW',
  storeMember: '$2a$10$s9xnEGxRDdXRzvK/n2SNKu0aVz2Tq6Y8Sw04tyLzaOs3077jQlLMi',
};

function extractBcryptHash(table, id) {
  const rowPrefix = `INSERT INTO \`${table}\` VALUES (${id},`;
  const row = sql.split('\n').find((line) => line.startsWith(rowPrefix));
  assert.ok(row, `missing ${table} seed row for ${id}`);

  const match = row.match(/'(\$2[aby]\$10\$[^']+)'/);
  assert.ok(match, `missing bcrypt hash in ${table} seed row for ${id}`);
  return match[1];
}

function assertMatchesMd5Password(hash, password) {
  const verifier = spawnSync(
    'python3',
    [
      '-c',
      [
        'import bcrypt, hashlib, sys',
        'password = sys.argv[1].encode("utf-8")',
        'hash_value = sys.argv[2].encode("utf-8")',
        'sys.exit(0 if bcrypt.checkpw(hashlib.md5(password).hexdigest().encode("utf-8"), hash_value) else 1)',
      ].join('\n'),
      password,
      hash,
    ],
    { encoding: 'utf8' },
  );

  assert.equal(verifier.status, 0, verifier.stderr || verifier.stdout);
}

test('sql seeds admin password as BCrypt(MD5(123456)) with a refreshed hash', () => {
  const adminHash = extractBcryptHash('li_admin_user', '1337306110277476352');

  assert.notEqual(adminHash, previousHashes.admin);
  assertMatchesMd5Password(adminHash, '123456');
});

test('sql seeds default store member password as BCrypt(MD5(111111)) with a refreshed hash', () => {
  const storeMemberHash = extractBcryptHash('li_member', '1376417684140326912');

  assert.notEqual(storeMemberHash, previousHashes.storeMember);
  assertMatchesMd5Password(storeMemberHash, '111111');
});
