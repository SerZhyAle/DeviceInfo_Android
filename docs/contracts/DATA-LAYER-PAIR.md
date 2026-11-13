# DATA-LAYER-PAIR - declaration

| Field | Value |
| --- | --- |
| **Id** | `DATA-LAYER-PAIR` |
| **Status** | Internal wire boundary (DeviceInfo phone <-> wear) |
| **Scope** | Disjoint prefix `/deviceinfo/` |
| **Carrier** | S0005 |

The phone-to-watch Data Layer communication in DeviceInfo operates strictly within this product's shared `applicationId`. Both packages share one application id and one Data Layer pair.

Message paths:
- `/deviceinfo/watch/system_info_report`: watch -> phone report payload
- `/deviceinfo/phone/system_info_report_ack`: phone -> watch acknowledgement

Paths use the dedicated `/deviceinfo/` prefix to guarantee complete isolation from FastMediaSorter's `/fms/` and Tourist's `/tourist/` routes.
