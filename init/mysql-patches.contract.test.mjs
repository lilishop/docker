import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import test from 'node:test';

const patchRunner = readFileSync(new URL('./mysql/999_apply_patches.sh', import.meta.url), 'utf8');
const goodsSchedulePatchUrl = new URL('./mysql/patches/001_goods_schedule_fields.sql', import.meta.url);
const bootstrapPatchUrl = new URL('./mysql/patches/002_bootstrap_schema_and_local_upload.sql', import.meta.url);
const afterSaleRefundPatchUrl = new URL('./mysql/patches/003_after_sale_refund_schema.sql', import.meta.url);
const goodsSearchParamPatchUrl = new URL('./mysql/patches/004_goods_search_param.sql', import.meta.url);

function assertNoUnguardedDdlDml(sql, label) {
  const unguarded = sql.split(/\r?\n/).filter((line) =>
    /^\s*(ALTER TABLE|UPDATE|INSERT)\s/i.test(line),
  );
  assert.equal(
    unguarded.length,
    0,
    `${label} must PREPARE ALTER/INSERT/UPDATE so missing base tables are skipped`,
  );
}

test('mysql docker init applies sql files from patches directory', () => {
  assert.match(patchRunner, /patch_dir="\/docker-entrypoint-initdb\.d\/patches"/);
  assert.match(patchRunner, /for patch_sql in "\$patch_dir"\/\*\.sql/);
  assert.match(patchRunner, /docker_process_sql --database="\$database" < "\$patch_sql"/);
  assert.match(patchRunner, /基表尚不存在/);
  assert.match(patchRunner, /基表已存在/);
});

test('mysql goods schedule patch alters li_goods only when the table exists and the column does not', () => {
  assert.equal(existsSync(goodsSchedulePatchUrl), true);
  const goodsSchedulePatch = readFileSync(goodsSchedulePatchUrl, 'utf8');

  assert.match(goodsSchedulePatch, /FROM information_schema\.TABLES/);
  assert.match(goodsSchedulePatch, /TABLE_NAME = 'li_goods'/);
  assert.match(goodsSchedulePatch, /AND NOT EXISTS \(/);
  assert.match(goodsSchedulePatch, /COLUMN_NAME = 'scheduled_upper_time'/);
  assert.match(goodsSchedulePatch, /ALTER TABLE `li_goods` ADD COLUMN `scheduled_upper_time`/);
  assertNoUnguardedDdlDml(goodsSchedulePatch, '001_goods_schedule_fields.sql');
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
  assert.match(bootstrapPatch, /TABLE_NAME = 'li_parameters'/);
  assert.match(bootstrapPatch, /TABLE_NAME = 'li_setting'/);
  assertNoUnguardedDdlDml(bootstrapPatch, '002_bootstrap_schema_and_local_upload.sql');
});

test('mysql bootstrap patch provides after-sale refund schema used by seller confirm receipt', () => {
  assert.equal(existsSync(afterSaleRefundPatchUrl), true);
  const afterSaleRefundPatch = readFileSync(afterSaleRefundPatchUrl, 'utf8');

  assert.match(afterSaleRefundPatch, /CREATE TABLE IF NOT EXISTS `li_order_gift_card_record`/);
  assert.match(afterSaleRefundPatch, /KEY `idx_li_order_gift_card_order` \(`order_sn`\)/);
  assert.match(afterSaleRefundPatch, /FROM information_schema\.TABLES/);
  assert.match(afterSaleRefundPatch, /AND NOT EXISTS \(/);
  assert.match(afterSaleRefundPatch, /TABLE_NAME = 'li_notice_message' AND COLUMN_NAME = 'scene_code'/);
  assert.match(afterSaleRefundPatch, /ALTER TABLE `li_notice_message` ADD COLUMN `scene_code`/);
  assert.match(afterSaleRefundPatch, /ALTER TABLE `li_wechat_message` ADD COLUMN `scene_code`/);
  assert.match(afterSaleRefundPatch, /ALTER TABLE `li_wechat_mp_message` ADD COLUMN `scene_code`/);
  assert.match(afterSaleRefundPatch, /AFTER_SALE_ROG_PASS/);
  assert.match(afterSaleRefundPatch, /AFTER_SALE_ROG_REFUSE/);
  assert.match(afterSaleRefundPatch, /skip li_notice_message update: table missing/);
  assertNoUnguardedDdlDml(afterSaleRefundPatch, '003_after_sale_refund_schema.sql');
});

test('mysql goods search param patch provides inverted index table with sku-aligned goods_id', () => {
  assert.equal(existsSync(goodsSearchParamPatchUrl), true);
  const goodsSearchParamPatch = readFileSync(goodsSearchParamPatchUrl, 'utf8');

  assert.match(goodsSearchParamPatch, /CREATE TABLE IF NOT EXISTS `li_goods_search_param`/);
  assert.match(goodsSearchParamPatch, /UNIQUE KEY `uk_li_goods_search_param_goods_name_value`/);
  assert.match(goodsSearchParamPatch, /KEY `idx_li_goods_search_param_lookup`/);
  assert.match(goodsSearchParamPatch, /`goods_id` varchar\(255\) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci/);
  assert.doesNotMatch(goodsSearchParamPatch, /utf8mb4_0900/);
});
