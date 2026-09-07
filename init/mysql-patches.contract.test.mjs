import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import test from 'node:test';

const patchRunner = readFileSync(new URL('./mysql/999_apply_patches.sh', import.meta.url), 'utf8');
const goodsSchedulePatchUrl = new URL('./mysql/patches/001_goods_schedule_fields.sql', import.meta.url);
const bootstrapPatchUrl = new URL('./mysql/patches/002_bootstrap_schema_and_local_upload.sql', import.meta.url);
const afterSaleRefundPatchUrl = new URL('./mysql/patches/003_after_sale_refund_schema.sql', import.meta.url);
const goodsSearchParamPatchUrl = new URL('./mysql/patches/004_goods_search_param.sql', import.meta.url);
const walletLogAlignPatchUrl = new URL('./mysql/patches/005_distribution_wallet_log_align.sql', import.meta.url);
const gradeHistoryRatePatchUrl = new URL('./mysql/patches/006_distribution_grade_history_rate.sql', import.meta.url);
const orderItemSnUniquePatchUrl = new URL('./mysql/patches/007_distribution_order_item_sn_unique.sql', import.meta.url);

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

test('mysql wallet log align patch renames 9 legacy columns only when old names exist', () => {
  assert.equal(existsSync(walletLogAlignPatchUrl), true);
  const walletLogAlignPatch = readFileSync(walletLogAlignPatchUrl, 'utf8');

  assert.match(walletLogAlignPatch, /FROM information_schema\.COLUMNS/);
  assert.match(walletLogAlignPatch, /TABLE_NAME = 'li_distribution_wallet_log'/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `log_type` `biz_type`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `can_rebate_before` `before_can_rebate`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `can_rebate_after` `after_can_rebate`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `commission_frozen_before` `before_commission_frozen`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `commission_frozen_after` `after_commission_frozen`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `withdrawal_frozen_before` `before_withdrawal_frozen`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `withdrawal_frozen_after` `after_withdrawal_frozen`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `withdrawn_total_before` `before_withdrawn_total`/);
  assert.match(walletLogAlignPatch, /CHANGE COLUMN `withdrawn_total_after` `after_withdrawn_total`/);
  assert.match(walletLogAlignPatch, /AND NOT EXISTS \(/);
  assert.match(walletLogAlignPatch, /COLUMN_NAME = 'biz_type'/);
  assert.match(walletLogAlignPatch, /skip li_distribution_wallet_log\.log_type/);
  assert.doesNotMatch(walletLogAlignPatch, /RENAME COLUMN/);
  assertNoUnguardedDdlDml(walletLogAlignPatch, '005_distribution_wallet_log_align.sql');
});

test('mysql grade history rate patch widens decimal(10,2) snapshot columns only when they exist', () => {
  assert.equal(existsSync(gradeHistoryRatePatchUrl), true);
  const gradeHistoryRatePatch = readFileSync(gradeHistoryRatePatchUrl, 'utf8');

  assert.match(gradeHistoryRatePatch, /FROM information_schema\.COLUMNS/);
  assert.match(gradeHistoryRatePatch, /TABLE_NAME = 'li_distribution_grade_history'/);
  assert.match(gradeHistoryRatePatch, /COLUMN_NAME = 'goods_commission_rate'/);
  assert.match(gradeHistoryRatePatch, /COLUMN_NAME = 'invite_commission_rate'/);
  assert.match(gradeHistoryRatePatch, /NUMERIC_PRECISION = 10/);
  assert.match(gradeHistoryRatePatch, /NUMERIC_SCALE = 2/);
  assert.match(gradeHistoryRatePatch, /MODIFY COLUMN `goods_commission_rate` DECIMAL\(10, 4\)/);
  assert.match(gradeHistoryRatePatch, /MODIFY COLUMN `invite_commission_rate` DECIMAL\(10, 4\)/);
  assert.match(gradeHistoryRatePatch, /skip li_distribution_grade_history\.goods_commission_rate/);
  assert.match(gradeHistoryRatePatch, /skip li_distribution_grade_history\.invite_commission_rate/);
  assert.doesNotMatch(gradeHistoryRatePatch, /^\s*CREATE TABLE/m);
  assert.doesNotMatch(gradeHistoryRatePatch, /ADD COLUMN/);
  assertNoUnguardedDdlDml(gradeHistoryRatePatch, '006_distribution_grade_history_rate.sql');
});

test('mysql distribution order item sn patch adds UNIQUE only when table exists and values are unique', () => {
  assert.equal(existsSync(orderItemSnUniquePatchUrl), true);
  const orderItemSnUniquePatch = readFileSync(orderItemSnUniquePatchUrl, 'utf8');

  assert.match(orderItemSnUniquePatch, /FROM information_schema\.TABLES/);
  assert.match(orderItemSnUniquePatch, /FROM information_schema\.STATISTICS/);
  assert.match(orderItemSnUniquePatch, /TABLE_NAME = 'li_distribution_order'/);
  assert.match(orderItemSnUniquePatch, /GROUP BY order_item_sn HAVING COUNT\(\*\) > 1/);
  assert.match(orderItemSnUniquePatch, /ADD UNIQUE KEY `uk_do_order_item_sn` \(`order_item_sn`\)/);
  assert.match(orderItemSnUniquePatch, /DROP INDEX `idx_do_order_item_sn`/);
  assert.match(orderItemSnUniquePatch, /INDEX_NAME = 'uk_do_order_item_sn'/);
  assert.match(orderItemSnUniquePatch, /INDEX_NAME = 'idx_do_order_item_sn'/);
  assert.match(orderItemSnUniquePatch, /skip li_distribution_order\.uk_do_order_item_sn: duplicate order_item_sn/);
  assert.match(orderItemSnUniquePatch, /skip li_distribution_order\.uk_do_order_item_sn/);
  assert.match(orderItemSnUniquePatch, /skip li_distribution_order\.idx_do_order_item_sn drop/);
  assert.doesNotMatch(orderItemSnUniquePatch, /DELETE FROM/);
  assertNoUnguardedDdlDml(orderItemSnUniquePatch, '007_distribution_order_item_sn_unique.sql');
});
