# R8 rules of the watch app's release variant (S0008). AGP's default optimize file and the consumer rules that
# Hilt, Compose, Timber and Google Play services ship cover the libraries; this file holds only what this code
# needs.

# The watch report crosses the Data Layer as Gson JSON. Gson fills these two classes by reflection and the field
# names are the wire format (pinned with @SerializedName, mirrored in the phone app), so both stay whole instead
# of relying on Gson's own rules, which the pinned gson 2.10.1 does not ship.
-keepattributes Signature, *Annotation*
-keep class com.sza.deviceinfo.wear.data.wear.WearSystemInfoReportPayload { *; }
-keep class com.sza.deviceinfo.wear.data.wear.WearSystemInfoReportAck { *; }
