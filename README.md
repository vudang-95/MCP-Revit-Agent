# DTV MCP – AI ↔ Revit (2021–2026)

Viết lại từ DeepBim-MCP: cùng **30 tool, cùng tên và tham số**. Không cần Node.js, không license, không gọi URL ngoài.

```
Desktop app / CLI-Agent / Cursor
        │  stdio (MCP, JSON-RPC 2.0)
DtvMcpBridge.exe  (net48 console, nằm cạnh add-in)
        │  TCP 127.0.0.1:8080-8099 (chỉ localhost)
DtvMcpRevit.dll   (add-in) → hàng đợi → 1 ExternalEvent → Transaction → Revit API
```

| Thư mục | Nội dung |
|---|---|
| `Installer/` | `Install.bat/.ps1`, `Uninstall.bat/.ps1`, `HUONG-DAN.txt` (được copy vào gói Release) |
| `Shared/` | `Json.cs` (JSON tự viết), `ToolCatalog.cs` (tên + schema tool), `McpSettings.cs` |
| `DtvMcpBridge/` | MCP server stdio + kho dữ liệu JSON cục bộ (`store_*`, `query_stored_data`) |
| `DtvMcpRevit/Core` | TCP server, `RevitDispatcher` (ExternalEvent), `RevitTx` (bắt warning/lỗi), log |
| `DtvMcpRevit/Tools` | Các tool Revit, `XlsxWriter` (ghi .xlsx không cần ClosedXML) |
| `DtvMcpRevit/UI` | Form Cobalt UI: MCP Server, MCP Settings, Export Sheets (`Themes/CbtTheme.xaml`) |

## Thư viện ngoài
Chỉ có **Microsoft.CodeAnalysis.CSharp 4.8.0** (Roslyn, NuGet chính thức của Microsoft), dùng cho `send_code_to_revit`. Roslyn chỉ được nạp khi gọi tool này, nên nếu lỗi nạp thì các tool khác vẫn chạy.
Còn lại chỉ dùng BCL + RevitAPI (ref assemblies net48 chỉ dùng lúc build).

## Build & phát hành
```powershell
.\build.ps1                          # build 2021..2026 (bỏ qua bản chưa cài Revit)
.\build.ps1 -Versions 2025 -Deploy   # build + cài vào %AppData%\Autodesk\Revit\Addins\2025 (dev)
.\release.ps1                        # build tất cả + đóng gói Release\MCP-Revit_<ver>\ và .zip
```
Người dùng: giải nén zip → bấm **Install.bat** (tự cài cho mọi Revit 2021–2026 có trên máy, không cần Admin); gỡ bằng **Uninstall.bat**.
TFM theo `Directory.Revit.props` dùng chung: 2021–2024 = net48, 2025 = net8, 2026 = net10.
Gói cài của mỗi bản: `DtvMcpRevit\bin\<ver>\Release\Deploy\` = `DTV_MCP.addin` + thư mục `DTV_MCP\`.

## Dùng
1. Mở Revit → tab **SVN-COF › MCP › MCP Server** (mặc định tự Start).
2. Bấm **Cài vào Desktop app** (gộp server `dtv-revit` vào `claude_desktop_config.json`, có sao lưu `.bak`), rồi thoát hẳn app và mở lại.
   - CLI-Agent: bấm **Copy lệnh CLI-Agent**, rồi chạy `claude mcp add dtv-revit -- "<...>\DtvMcpBridge.exe"`.
   - Cursor / các client khác: bấm **Copy JSON config**.
3. **CLI-Agent Chat** (Dockable Pane trong Revit): dùng CLI-Agent đã cài và đăng nhập (`claude` → `/login` một lần). Mỗi hội thoại chạy nền `claude -p --input-format/--output-format stream-json` và chỉ nạp MCP `dtv-revit` (`--strict-mcp-config`); các tool Bash/Edit của CLI bị tắt.
   - Tool chỉ đọc chạy ngay. Tool sửa model đi qua `--permission-prompt-tool` → bridge (`--chat`) → add-in → hiện thẻ **Cho phép / Luôn cho phép / Từ chối** trong khung chat.
   - Model: chọn trên thanh công cụ (Mặc định / Sonnet / Opus / Haiku). **Dừng** giữ hội thoại (`--resume`), **Mới** mở hội thoại mới.
4. **MCP Settings**: bật/tắt từng tool, đổi port, timeout. Settings lưu ở `%AppData%\DTV\McpRevit\settings.json`, log lưu ở `...\logs\`.

## Khác bản cũ
- `ai_element_filter.boundingBoxMin/Max` là `{x,y,z}` (mm), khớp đúng handler cũ (schema TS cũ ghi nhầm `p0/p1`).
- `operate_element` có thêm action `ResetGraphics`.
- `create_line_based_element` hỗ trợ thêm ống (`OST_PipeCurves`) và model line (`OST_Lines`). Tường: tự tìm type có đúng độ dày, không có thì nhân bản type `DTV Wall <t>mm`. Sàn cũng vậy.
- `create_surface_based_element` với trần (`OST_Ceilings`): Revit 2021 chưa có API tạo trần.
- Kho `store_project_data` / `store_room_data` / `query_stored_data` lưu vào `%AppData%\DTV\McpRevit\project-data.json` thay cho SQLite.

## Tool bổ sung (v0.0.1)
| Tool | Việc |
|---|---|
| `get_element_parameters` / `set_parameters` | Đọc / sửa tham số hàng loạt (tên hiển thị theo ngôn ngữ Revit hoặc tên BuiltInParameter; số = đơn vị hiển thị) |
| `transform_elements` | move / copy (lặp N lần) / rotate / mirror |
| `create_view`, `create_sheets`, `place_views_on_sheet` | Tạo/nhân bản view, tạo sheet, đặt view/bảng thống kê lên sheet |
| `capture_view_image` | Chụp view (JPEG) trả về ảnh cho AI xem; khung chat hiện thumbnail |
| `check_untagged_elements` | Element chưa tag trong view hiện hành, theo category, tùy chọn chọn sẵn |
| `export_model_rvt` | Xuất .rvt riêng; model cloud BIM 360/ACC mở tách rời ở nền rồi Save As (model đang mở không đổi) |
| `export_ifc`, `export_dwg` | Xuất IFC (chọn phiên bản, lọc theo view) / DWG (dùng DWG export setup của công ty) |

`ai_element_filter`, `get_selected_elements` có thêm `parameterNames` / `includeParameters` để giảm token. Tool xuất file có timeout riêng 30 phút.
Checklist test: `TEST-CHECKLIST.md`.
