# CLAUDE.md

## Rules
- Trả lời ngắn gọn, không suy đoán/bịa API. Đọc file để xác nhận khi thiếu info.
- Chỉ sửa đúng phạm vi yêu cầu, không refactor diện rộng, không tự thêm NuGet.
- Tìm bằng grep/glob trước khi mở file; không đọc lại file chưa đổi.
- Bỏ qua: bin/, obj/, .vs/, .git/, *.g.cs, *.g.i.cs, *.Designer.cs, *.baml

## Output style
- Không tường thuật quá trình: cấm "Trước khi…", "Để tôi…", "Chẩn đoán xong…", "Giờ tôi sẽ…".
- Cho phép suy luận tối đa 1–2 câu để nêu gốc vấn đề; không kể lại từng bước đã làm.
- Mỗi file đọc 1 lần/phiên, nhớ nội dung; không đọc lại file chưa đổi (kể cả để "xác nhận").
- Kết thúc task chỉ báo: **nguyên nhân (1 câu) → file + dòng đã sửa → build status**.
- Bảng, giải thích dài, so sánh phương án: chỉ khi được hỏi.

## Architecture Discovery
Đầu mỗi phiên làm việc, nếu có `graphify-out/`, tự chạy staleness check ngay (không cần đợi yêu cầu phân tích kiến trúc).

Nếu có `graphify-out/`, đọc theo thứ tự trước khi phân tích/refactor/tìm entry point:
1. GRAPH_REPORT.md → 2. _graphify_analysis.json → 3. graph.json
Xác định Community / Hotspot classes / Dependencies rồi mới đọc source.

**Staleness check (scope vào source, bỏ rác build):**
`find . -name "*.cs" -not -path "*/obj/*" -not -path "*/bin/*" -not -path "*/.vs/*" -newer graphify-out/graph.json`
Nếu có file source mới hơn → báo, không tự chạy khi chưa xác nhận. Không dùng graph cũ để kết luận entry point/dependency nếu source liên quan đã đổi.

## Graphify update (tiết kiệm token)
Quy tắc quyết định **có chạy hay không**:
- Đổi *quan hệ giữa class* (thêm/xóa/đổi tên class, đổi chữ ký method public, đổi dependency/entry point) → update.
- Đổi *bên trong thân method* (sửa logic/guard/màu…) → **KHÔNG rescan**, graph không đổi. Báo "không cần rescan" và dừng.

Khi cần update thì chạy **incremental**, không full rescan:
- Giữ `manifest.json` + `cache/` (graphify tự diff hash, file không đổi thì skip). KHÔNG xóa mỗi lần — xóa = ép full rescan = đắt.
- Ignore bắt buộc khi scan: `bin/ obj/ .vs/ *.g.cs *.Designer.cs`. Nếu log hiện community rác (C1x+) hoặc chạy AST 2 lượt → ignore chưa có tác dụng: kiểm config graphify + xóa `manifest.json` 1 lần cho sạch, rồi scan lại.
- Với add-in mới: khai báo ignore TRƯỚC lần scan đầu để manifest sạch từ gốc → mọi update sau đều nhẹ.
- Output khi update: số node/edge thay đổi + cảnh báo (nếu có), không tường thuật.

## Trước khi sửa (rủi ro cao)
- Đổi Transaction/ExternalEvent/threading hoặc cross nhiều file → tóm tắt kế hoạch trước.
- Không chắc phạm vi ảnh hưởng → hỏi lại, không tự mở rộng.
- Tóm tắt kế hoạch = gạch đầu dòng ngắn (gốc + hướng sửa), không phải tường thuật từng lượt đọc file.

## Revit
- Target: Revit 20XX (.NET 8 / .NET Framework 4.8 nếu multi-target); không dùng API deprecated.
- Transaction bắt buộc cho mọi thay đổi model; không gọi Revit API từ background thread.
- Modeless UI → ExternalEvent. Internal Unit = Feet. Cache ElementId, không cache Element.
- Ưu tiên FilteredElementCollector với OfClass()/OfCategory().
- Workflow: UI → ViewModel → ExternalEvent → Handler → Transaction → Revit API
- Ưu tiên tìm: IExternalCommand, IExternalApplication, ExternalEvent, RequestHandler, EventFactory, RevitHelper
- Thao tác view (ActiveView/RequestViewChange/Zoom/Close) là UI, không đặt trong Transaction; đổi active view giữa vòng lặp nhiều view → hoãn qua Idling/ExternalEvent.

## Build & Test
`dotnet build` → sửa hết lỗi liên quan, không kết luận xong khi còn lỗi compile.
Nếu có test project: `dotnet test` các test liên quan; không kết luận xong nếu fail.

## Style
PascalCase (Class/Method/Property), _camelCase (private field), C# 12/.NET 8, code đơn giản dễ đọc.
