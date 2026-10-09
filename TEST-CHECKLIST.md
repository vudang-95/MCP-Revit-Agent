# Checklist test MCP Revit trong Revit

Mở một model thử (nên dùng bản copy, **không dùng model thật của dự án**), vào **SVN-COF › MCP › CLI-Agent Chat**, gõ lần lượt từng câu.
Ghi ✅ / ❌. Câu nào ❌ thì copy nguyên thông báo lỗi (hoặc bấm vào dòng tool để xem "Kết quả") gửi lại.

## A. Đọc dữ liệu (không sửa model, không hỏi xác nhận)
| # | Câu gõ | Mong đợi | KQ |
|---|---|---|---|
| 1 | Thông tin view đang mở | Tên view, loại, scale, level | |
| 2 | Chụp ảnh view hiện tại cho tôi xem | Có ảnh thumbnail trong khung chat, AI mô tả được | |
| 3 | Thống kê model theo category | Bảng số lượng theo category + level | |
| 4 | Liệt kê 10 cột kết cấu, chỉ lấy tên type và level | Dùng `ai_element_filter` với `parameterNames`, kết quả gọn | |
| 5 | Chọn vài element trong Revit rồi hỏi: "Các element đang chọn là gì?" | Đúng số lượng và loại | |
| 6 | Đọc tham số của element đang chọn, có cả tham số type | Có tên tham số, kiểu, chỉ đọc hay không | |
| 7 | Kiểm tra trong view này đối tượng nào chưa có tag và chọn chúng | Bảng theo category, Revit tô chọn các element chưa tag | |
| 8 | Liệt kê phòng và diện tích | Danh sách phòng m², tổng | |
| 9 | Bóc khối lượng vật liệu tường và sàn | Bảng vật liệu m², m³ | |

## B. Sửa model (luôn có thẻ xin phép, thử cả **Từ chối** lẫn **Cho phép**)
| # | Câu gõ | Mong đợi | KQ |
|---|---|---|---|
| 10 | Tạo level "TEST L1" cao 12000mm | Level + floor plan mới | |
| 11 | Tạo 2 tường dài 5000mm dày 200mm ở tầng hiện tại, bắt đầu từ gốc toạ độ | 2 tường, đúng dày | |
| 12 | Đặt 1 cửa đi vào giữa bức tường vừa tạo | Cửa nằm trên tường | |
| 13 | Đặt Comments = "MCP test" cho các tường vừa tạo | `set_parameters` OK, kiểm tra trong Properties | |
| 14 | Copy 2 tường đó sang phải 6000mm, 3 lần | 6 tường mới | |
| 15 | Xoay các tường vừa copy 30 độ | Xoay quanh tâm nhóm | |
| 16 | Tô màu đỏ các tường vừa tạo trong view | Override màu đỏ | |
| 17 | Tag tất cả tường trong view | Tag ở giữa tường, bỏ qua tường đã có tag | |
| 18 | Tạo mặt bằng mới cho level "TEST L1" tên "MCP Plan" scale 1:50 | View mới | |
| 19 | Tạo sheet "MCP-01 Test" rồi đặt view "MCP Plan" lên sheet | Sheet + viewport | |
| 20 | Xoá các tường, cửa, level đã tạo khi test | Xoá xong, Ctrl+Z vẫn hoàn tác được | |

## C. Xuất file (hỏi xác nhận, có thể chạy vài phút)
| # | Câu gõ | Mong đợi | KQ |
|---|---|---|---|
| 21 | Xuất view hiện tại ra DWG, cho tôi biết các DWG export setup có sẵn | File .dwg trong Documents\MCP-Export\<model>\DWG | |
| 22 | Xuất IFC4 chỉ các element trong view 3D hiện tại | File .ifc | |
| 23 | Xuất model ra file .rvt riêng (model BIM 360) | File .rvt local, model đang mở không đổi | |
| 24 | Xuất danh sách sheet ra Excel với số và tên sheet | File .xlsx mở được | |

## D. Giao diện / hệ thống
| # | Việc | Mong đợi | KQ |
|---|---|---|---|
| 25 | Nút Usage (đồng hồ) | % phiên / tuần + giờ reset | |
| 26 | Đổi model sang Haiku + mức suy nghĩ "Thấp", hỏi tiếp | Vẫn nhớ hội thoại, trả lời nhanh hơn | |
| 27 | Bấm Dừng khi đang trả lời, rồi gửi tiếp | Dừng ngay, hỏi tiếp bình thường | |
| 28 | MCP Server → Stop, hỏi AI một câu | AI báo không kết nối được Revit | |
| 29 | MCP Settings → tắt `delete_element`, bấm Mới, bảo AI xoá 1 element | AI không có tool xoá | |
| 30 | `send_code_to_revit`: "Dùng code C# trả về số lượng tường" (thử trên 2024 và 2025) | Có kết quả số | |
| 31 | Hỏi "liệt kê 3 cột kèm ID", bấm vào số ID / link trong câu trả lời | Revit chọn và zoom tới element | |
| 32 | Đang trả lời bấm nút "Dừng" phía trên ô nhập hoặc phím Esc | Dừng ngay, gửi tiếp vẫn nhớ hội thoại | |
| 33 | Nút giao diện (header): Tự động → Sáng → Tối; Revit 2024+ đổi theme Revit (Options → Colors) khi đang Tự động | Khung chat đổi màu ngay, không cần mở lại | |
| 34 | Mở Revit 2022 + 2025 cùng lúc, chat trong từng Revit hỏi "thông tin view đang mở" | Mỗi khung chat trả đúng model của Revit đó; MCP Server 2022 = cổng 8081, 2025 = 8084 | |
| 35 | Trong Revit bấm một lệnh (vd. Wall, đang vẽ dở) rồi hỏi chat | Sau ~10s báo "Revit chưa nhận lệnh... nhấn Esc", không chờ 2 phút | |
| 36 | Cho AI đổi type hàng loạt trên model lớn (lệnh chạy > 2 phút) | Chat báo "VẪN ĐANG CHẠY - không gửi lại", AI không chạy lại; nhật ký MCP Server ghi "xong muộn sau …s" | |
| 37 | Mở Revit → CLI-Agent Chat | Mở khung dock; header có dòng xám "Revit 20xx · tên model", đổi view sang model khác thì dòng này đổi theo | |
| 38 | Bấm nút "Tách cửa sổ" khi đang có hội thoại | Hiện cửa sổ "CLI-Agent · Revit 20xx" có thu nhỏ/phóng to, hội thoại giữ nguyên; khung dock ẩn | |
| 39 | Ở cửa sổ riêng, cho AI chạy lệnh lâu (vd. đổi type hàng loạt) | Trong lúc Revit chạy vẫn cuộn/gõ/bấm Dừng được | |
| 40 | Bấm "Dock vào Revit" rồi đóng/mở lại Revit, bấm ribbon | Hội thoại chuyển về dock; lần mở Revit sau luôn mở dạng dock | |

## Kết quả test tự động — 08/10/2026 (Revit 2024.3, model mẫu Snowdon Towers Architectural, bản sao)

Chạy qua giao thức MCP thật (bridge → add-in), script `mcp_fulltest.py`: **45/45 đạt** (1 ca lần đầu "không đạt" là hành vi đúng: view dùng template → tool yêu cầu áp filter vào template; áp vào template: đạt).

| Nhóm | Kết quả |
|---|---|
| Kết nối / chọn Revit | tools/list 50 tool; `--revit 2025` khi chỉ mở 2024 → dùng Revit duy nhất; khung chat sai process → từ chối |
| Tool đọc (12) | đạt hết; `check_untagged_elements`, `color_elements` thêm `viewId` (trước đây chỉ dùng view đang mở) |
| run_code_readonly | đọc, chạy thử (model không đổi), báo số element theo category, chặn ghi file / Save() |
| send_code_to_revit | có `title` (tên Undo "CLI-Agent: …"), ghi thật và đọc lại đúng |
| Tool sửa (14) | level, tường, set/đổi type, move, view, sheet, đặt view, tag, dim, text, filter, template, tô màu, xóa |
| Xuất file | IFC (~93s toàn model), DWG, Excel sheet |
| Revit bận | lệnh mới bị từ chối sau 10s kèm lý do; lệnh dài 25s vẫn xong |

Lưu ý hiệu năng: `tag_elements` 194 tag mất ~110s (chậm, có thể tối ưu sau).
Chưa tự động được (cần thao tác tay): thẻ hỏi quyền, khung chat dock/cửa sổ riêng, theme, đính kèm, lịch sử, bấm link element, mục 21–33, 37–40.
