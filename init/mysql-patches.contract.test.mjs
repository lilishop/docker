import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import test from 'node:test';

const patchRunner = readFileSync(new URL('./mysql/999_apply_patches.sh', import.meta.url), 'utf8');
const bootstrapPatchUrl = new URL('./mysql/patches/002_bootstrap_schema_and_local_upload.sql', import.meta.url);
const afterSaleRefundPatchUrl = new URL('./mysql/patches/003_after_sale_refund_schema.sql', import.meta.url);

test('mysql docker init applies sql files from patches directory', () => {
  assert.match(patchRunner, /patch_dir="\/docker-entrypoint-initdb\.d\/patches"/);
  assert.match(patchRunner, /for patch_sql in "\$patch_dir"\/\*\.sql/);
  assert.match(patchRunner, /docker_process_sql --database="\$database" < "\$patch_sql"/);
});

test('mysql bootstrap patch provides category parameter table and local upload setting', () => {
  assert.equal(existsSync(bootstrapPatchUrl), true);
  const bootstrapPatch = readFileSync(bootstrapPatchUrl, 'utf8');

  assert.match(bootstrapPatch, /CREATE TABLE IF NOT EXISTS `li_category_parameter`/);
  assert.match(bootstrapPatch, /INSERT IGNORE INTO `li_category_parameter`/);
  assert.match(bootstrapPatch, /INSERT INTO `li_setting`/);
  assert.match(bootstrapPatch, /ON DUPLICATE KEY UPDATE/);
  assert.match(bootstrapPatch, /"type":"LOCAL"/);
  assert.match(bootstrapPatch, /"localFilePath":"data\/uploads"/);
  assert.match(bootstrapPatch, /"localFileUrlPrefix":"\/files"/);
});

test('mysql bootstrap patch provides after-sale refund schema used by seller confirm receipt', () => {
  assert.equal(existsSync(afterSaleRefundPatchUrl), true);
  const afterSaleRefundPatch = readFileSync(afterSaleRefundPatchUrl, 'utf8');

  assert.match(afterSaleRefundPatch, /CREATE TABLE IF NOT EXISTS `li_order_gift_card_record`/);
  assert.match(afterSaleRefundPatch, /KEY `idx_li_order_gift_card_order` \(`order_sn`\)/);
  assert.match(afterSaleRefundPatch, /TABLE_NAME = 'li_notice_message' AND COLUMN_NAME = 'scene_code'/);
  assert.match(afterSaleRefundPatch, /ALTER TABLE `li_notice_message` ADD COLUMN `scene_code`/);
  assert.match(afterSaleRefundPatch, /ALTER TABLE `li_wechat_message` ADD COLUMN `scene_code`/);
  assert.match(afterSaleRefundPatch, /ALTER TABLE `li_wechat_mp_message` ADD COLUMN `scene_code`/);
  assert.match(afterSaleRefundPatch, /AFTER_SALE_ROG_PASS/);
  assert.match(afterSaleRefundPatch, /AFTER_SALE_ROG_REFUSE/);
});
