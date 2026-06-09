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
3. 浏览器应下载 `SOW_{项目编号}_{时间}.docx`
4. 打开 Word，核对：
   - 封面/正文中的 `{{ContractName}}`、`{{ContractNo}}` 已替换
   - 样例客户名「孙吴县乡村振兴服务中心」已替换为立项甲方
   - 产品范围、组织范围、实施功能范围、初始数据转换范围、培训服务、系统集成范围、上线支持表格已按立项子表刷新
