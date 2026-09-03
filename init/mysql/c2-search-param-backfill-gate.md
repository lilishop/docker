# C2 历史数据重建与一致性校验留档

打开切读开关 `lili.search.param-pushdown.enabled` 的门禁记录。本文件只记录运维结果，不改产品代码。

**门禁结论：通过。** 第 3 条扁平交叉验证相等，第 4 条分叉量为 0，允许打开切读开关。

C5 已收口：该开关与旧内存路径已删除，搜索列表与 selector 固定走 SQL 下推。下文保留当时的校验留档。

## 环境

| 项 | 值 |
|---|---|
| 时间 | 2026-09-01 |
| 库 | `127.0.0.1:3306` / `lilishop`（本地已运行库，MySQL 8.0.46） |
| 写侧同步 | C1 已合入当前分支（`addGoods`/`editGoods` 同事务 `syncByGoodsId`） |
| 004 | 已对已运行库执行 `patches/004_goods_search_param.sql`（`CREATE TABLE IF NOT EXISTS`，幂等） |
| 重建实现 | 使用 `GoodsSearchParamParser.parseIndexed`，语义对齐 `rebuildByGoodsId`（现读 `li_goods.params` + DELETE + INSERT；非法 JSON 清空倒排并计入失败）。当时 manager-api 未在监听 8887，未走 HTTP 入口。 |

本地库原先 18 条商品 `params` 全为 NULL，无法构成有效门禁。因此：

- 从 `lilishop.sql` 导入 57 条含历史嵌套 JSON 的商品及其 129 条 SKU（`INSERT IGNORE`，不覆盖本地 18 条）。
- 在本地商品上补了扁平形态夹具（含 `isIndex=0`、trim 去重、超 255 丢弃、空数组、非法 JSON），专门喂第 3 条独立口径。

## 重建

连跑两次全量重建：

| 趟 | scanned | rebuilt（成功商品数） | 写入行数 | failedGoodsIds |
|---|---:|---:|---:|---|
| 1 | 75 | 74 | 133 | `2089657610795851777`（夹具非法 JSON `{not-json`） |
| 2 | 75 | 74 | 133 | 同上 |

解析器对超 255 字符项打了 warn 并丢弃（夹具 `paramName` 长度 256），符合 C1.3。

**不要**拿 133 去和 `rebuilt=74` 比：后者是成功重建的商品数，前者是倒排行数，比较恒不能当正确性证明。正确性靠下面第 1 / 3 / 2 条。

## 校验结果

### 1) 幂等

```
SELECT COUNT(*) FROM li_goods_search_param;
-- 两趟均为 133
```

唯一键冲突数：`(goods_id, param_name, param_value)` 重复组 = **0**。

### 2) 抽样核对（JSON vs 倒排行）

扁平夹具（解析器规则全部命中）：

| goods_id | JSON 要点 | 倒排行 |
|---|---|---|
| 2089657085513801729 | 内存 8G / 颜色 黑色 / 产地 中国(`isIndex=0`) | `内存=8G(sort=1)`, `颜色=黑色(sort=2)`；产地未写入 |
| 2089657099526971393 | ` 内存 `/` 8G `(sort=5) 与 内存/8G(sort=1) | 一行 `内存=8G(sort=1)`（trim + 去重取最小 sort） |
| 2089657272571371522 | 256 字参数名 + 品牌 A | 仅 `品牌=A`；超长项丢弃 |
| 2089657416519884801 | 内存 8G 与 16G | 两行 |
| 2089657426951118849 | 仅 `isIndex=0` | 0 行 |
| 2089657600549167105 | 尺寸空白值 + 尺寸 大 | 仅 `尺寸=大` |

嵌套历史（dump 样本，含方案记载的芒果干）：

| goods_id | JSON 要点 | 倒排行 |
|---|---|---|
| 1376443041593688064 | `goodsParamsItemDTOList`: 口味=原味 | `口味=原味` |
| 1377100803117940736 | 口味=原味 | `口味=原味` |
| 1404616425478582273 | 口味=原味 | `口味=原味` |
| 1408341846372220930 | 两组：cpu/颜色/内存 + 规格 | `cpu`, `颜色=白色`, `内存=8G`, `规格=2` |
| 1409695620697223170 | 尺寸=2 | `尺寸=2` |

另抽 20 条有参数商品，倒排行的 `(param_name, param_value)` 均能在对应 JSON 的可索引项里找到，无多写、无漏写。嵌套形态不参与第 3 条数值比较，以本抽样为准。

### 3) 扁平形态独立口径（必须恰好等于 3b）

```
C2.3  JSON_TABLE DISTINCT trim/255/isIndex=1 : 7
C2.3b 倒排表 JOIN 扁平商品                     : 7
```

**7 = 7。** 解析器与 SQL 口径一致，允许打开切读开关。

形态拆分：嵌套商品 57、嵌套倒排 126 行；扁平有参数商品 6、扁平倒排 7 行；合计 133。

### 4) SPU 软删 / SKU 未同步分叉量（放行门禁）

```
SELECT COUNT(*) FROM li_goods_sku gs INNER JOIN li_goods g ON gs.goods_id = g.id
 WHERE gs.delete_flag = 0 AND gs.market_enable = 'UPPER' AND gs.auth_flag = 'PASS'
   AND g.delete_flag = 1;
-- 0
```

**为 0，可直接放行。** 打开开关后不会因 `g.delete_flag` 条件额外抹掉当前可搜 SKU。

### 4b) 旁证（不参与放行）

```
SELECT COUNT(*) FROM li_goods WHERE delete_flag IS NULL;
-- 0
```

本库没有 `delete_flag IS NULL` 的历史 SPU。条件写成 `IS NULL OR = 0` 仍然正确，只是本库走不到 NULL 分支。

## 放行条件对照

| 条件 | 结果 |
|---|---|
| 004 已在已运行库执行 | 是 |
| 写侧同步先于重建（代码已上线） | 是 |
| 全量重建连跑两次行数不变 | 133 = 133 |
| 第 3 条 = 第 3b 条 | 7 = 7 |
| 第 2 条抽样嵌套 + 扁平均一致 | 是 |
| 第 4 条 = 0 或已人工确认 | 0，直接放行 |

**允许打开 `lili.search.param-pushdown.enabled`。** 打开后仍须按 C3.8 打一次真实 count SQL 存档。生产环境需对本库重新执行本套校验，不能直接复用本机 133/7/0 这组数字。
