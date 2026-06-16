# SOW 模板 4.1 实施策略表调整说明

## 背景

项目立项「实施策略」已改为**结构化子表**（`pi_project_implementation_strategy_line`），生成 SOW 时由 `SowTableMapper.ApplyImplementationStrategyTable` 自动填充 Word 表格，**不再使用**主表富文本字段 `ImplementationStrategy`。

## 模板文件位置

```
MalusAdmin.WebApi/Templates/SOW/实施工作说明书(SOW)_Template_V1.2.docx
```

详细列定义见同目录 `README.md`。

## Word 中如何调整（操作步骤）

### 1. 定位 4.1 节

找到章节 **「4.1 实施策略」**，其下应有固定说明段落：

> 本项目整体实施策略如下：

说明文字保留在**表格外**（段落），不要放进表格。

### 2. 表格结构

使用 **2 行表头 + 1 行样例数据**（样例行即程序克隆的样式模板）。

```
┌────┬──────────┬──────────┬────────────┬────────┬──────── 推广策略 ────────┬──────────── 实施地点 ────────────┐
│序号│ 业务板块 │ 组织范围 │下属分支机构│分期策略│ 试点 │ 推广 │推广责任方│集中│分散│异地集中│异地分散│
├────┼──────────┼──────────┼────────────┼────────┼──────┼──────┼──────────┼────┼────┼────────┼────────┤
│ 1  │财务+供应链│孙吴县…  │ 4家组织    │ 一期   │  √   │  √   │ 甲、乙方 │ √  │    │        │        │
└────┴──────────┴──────────┴────────────┴────────┴──────┴──────┴──────────┴────┴────┴────────┴────────┘
```

### 3. 合并单元格规则

- **仅表头两行**可使用横向/纵向合并
- **第 3 行（数据模板行）禁止合并**，必须是 **12 个独立单元格**
- 表头背景色、字体可与现有 SOW 其他表保持一致（浅蓝表头）

### 4. 在 Word 中设置合并（示例）

1. 插入 3 行 × 12 列表格（或按现有模板改）
2. 选中「推广策略」右侧 2 格 → 合并 → 得到跨 3 列
3. 选中「实施地点」右侧 3 格 → 合并 → 得到跨 4 列
4. 第 2 行在「试点」起依次填入子列名
5. 第 3 行填满 12 格样例（用于样式，生成时会被立项数据覆盖）

### 5. 保存与部署

1. 保存 docx 到 `Templates/SOW/` 目录
2. 重启 WebApi（或确保 `ResolveTemplatePath` 能读到最新文件）
3. 运行校验脚本（见下）
4. 项目立项 → 填写实施策略 → 生成 SOW → 打开 Word 核对

## 校验

```powershell
# 校验模板表结构（12 列、关键字）
powershell -ExecutionPolicy Bypass -File "doc/validate-sow-implementation-strategy-table.ps1"

# 端到端生成 SOW
powershell -ExecutionPolicy Bypass -File "doc/test-project-init-sow.ps1"
```

## 数据流

```mermaid
flowchart LR
  A[立项-实施策略页签] --> B[pi_project_implementation_strategy_line]
  B --> C[GenerateSow API]
  C --> D[FindImplementationStrategyTable]
  D --> E[克隆模板第3行并填12列]
  E --> F[输出 docx]
```

## 与立项页签字段对应

前端 `ProjectImplementationStrategyLine` 与 SOW 12 列一一对应，勾选列在 SOW 中输出 `√` 或空白。
