# 项目立项生成 SOW 联调测试

## 前置

1. 执行权限 SQL：`doc/sql/add-project-init-generate-sow-permission-role49.sqlserver.sql`
2. 确认模板存在：`MalusAdmin.WebApi/Templates/SOW/实施工作说明书(SOW)_Template_V1.2.docx`
3. 重启 WebApi 后重新登录（刷新按钮权限）

## 自动测试

```powershell
powershell -ExecutionPolicy Bypass -File "doc/test-project-init-sow.ps1"
```

## 手工验证

1. 打开「项目立项」列表
2. 点击某一行的 **生成SOW**
3. 浏览器应下载 `实施工作说明书（SOW）_{客户名称}_V2.1.docx`（客户名称取自立项客户名称，缺省时回退甲方/项目名称）
4. 打开 Word，核对：
   - 封面/正文中的 `{{ContractName}}`、`{{ContractNo}}` 已替换
   - 样例客户名「孙吴县乡村振兴服务中心」已替换为立项甲方
   - 产品范围、组织范围、实施功能范围、初始数据转换范围、培训服务、系统集成范围、上线支持表格已按立项子表刷新
   - **4.1 实施策略**表格已按「实施策略」页签子表刷新（12 列：业务板块、推广策略勾选、实施地点勾选等；模板调整见 `doc/SOW模板-4.1实施策略表说明.md`）
   - 「1.2 相关文档」中 `{{SowReferenceDocumentList}}` 已按「SOW撰写参考文档」页签上传顺序替换（`《《文件名》》` 格式，不含合同主相关行）

## 实施策略模板预检

```powershell
powershell -ExecutionPolicy Bypass -File "doc/validate-sow-implementation-strategy-table.ps1"
```

若生成时报错「模板数据行应有 12 列」，请在 Word 中将 4.1 实施策略表**第 3 行（样例数据行）**改为 12 个未合并单元格。
