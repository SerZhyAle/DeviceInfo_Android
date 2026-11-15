# Google Play Data safety, content rating and declarations

The answers the owner enters in the Play Console, written down flow by flow so the form, the hosted privacy page
(`site/privacy*.html`) and the permission list (`docs/SECURITY_INVENTORY.md`) say the same thing. If a flow of the app
changes, the inventory, the page and this file change in one edit; a mismatch is a common review rejection.

## Data safety form

| Question | Answer | Why it is true |
| --- | --- | --- |
| Does the app collect or share any of the required user data types? | No | The app reads device information on the device and shows it there. Neither package declares `INTERNET`, there is no server, no analytics and no advertising code (`docs/SECURITY_INVENTORY.md`, section 2). |
| Is all of the user data collected by the app encrypted in transit? | Not applicable | No data is collected. |
| Does the app provide a way to request deletion of data? | Not applicable | No data is collected; uninstalling the app removes everything it stores. |
| Data types: location, personal info, financial, health and fitness, messages, photos and videos, audio, files, calendar, contacts, app activity, web browsing, app info and performance, device or other IDs | None collected, none shared | See the flows below. |

### Flows, one row each

| Flow | Leaves the device | Declared as |
| --- | --- | --- |
| Reading the device information and showing it | No | Processed on the device only; not collected. |
| Copy, Copy section | To the clipboard, on the user's tap | Not collected: the developer receives nothing. |
| Save | To the Downloads folder of the same phone, on the user's tap | Not collected. |
| Share | To the app the user picks in the Android share sheet, on the user's tap | Not collected and not shared by the developer: the user chooses the destination. |
| Send to phone (watch to phone), and the acknowledgment back | Between the user's own paired watch and phone, through the Wearable Data Layer of Google Play services, on the user's tap | Not collected and not shared: a transfer between the user's own devices, handled by Google Play services as the platform, never by a server of the developer. |
| Google Play's own statistics (installs, crash and ANR rates) | From devices whose owners share them with Google | Provided to the developer by Google Play in aggregate; the app sends nothing. |

### Security practices

- Data is not collected, so the "encrypted in transit" and "deletion request" declarations are marked not applicable.
- The app does not follow the Families policy: it is not designed for children and has no child-directed features.

## App content

| Item | Answer |
| --- | --- |
| Ads | No ads |
| App access | All functionality is available without any account or special access |
| Target audience | Not designed for children; 18 and over is selected |
| News app, COVID-19 app, government app, financial features, health features | No |
| Permissions declaration forms | None needed: the only sensitive-looking permission is the runtime permission `POST_NOTIFICATIONS`, which needs no declaration form |
| Declared permissions | Phone: `ACCESS_NETWORK_STATE` (network state), `POST_NOTIFICATIONS` (the watch report notification); watch: `ACCESS_WIFI_STATE` (Wi-Fi bands) - each with its one-sentence justification in `docs/SECURITY_INVENTORY.md` section 1 |
| Advertising ID | Not used |

## Content rating (IARC)

A fresh questionnaire is filed for this app by the owner in the Play Console; a rating id of another portfolio app is
never copied (canon `SECURITY_AND_PRIVACY.md`, section 5). Category: **Utility, productivity, communication or other**.
Answers: violence, sexuality, language, controlled substances, gambling, horror - none; user-generated content - none;
user-to-user communication - none; sharing of the user's location - none; digital purchases - none; unrestricted internet
access - none (the app has no internet permission); the app is not a web browser or a search engine.

## Wear OS

The watch package is uploaded to the same app under the Wear OS form factor. Its manifest declares
`android.hardware.type.watch` and `com.google.android.wearable.standalone` set to true, so it also runs without the phone
app. The phone and the watch app share the application id and the signing certificate, which is what routes the Data Layer
messages between them (`DATA-LAYER-PAIR`), and the disjoint version-code bands (`PACKAGE-VERSIONING`) let both packages
sit under one id.
