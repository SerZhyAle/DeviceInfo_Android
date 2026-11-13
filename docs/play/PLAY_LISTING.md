# Google Play listing sources

The text of the store listing of DeviceInfo, phone and watch in one listing (application id `com.sza.deviceinfo`), in the
three authored languages. This file is the single source: the Play Console fields are filled from it, never the other way
round. Limits: title 30, short description 80, full description 4000, release notes 500 characters.

## Console fields

| Field | Value |
| --- | --- |
| App name | DeviceInfo |
| Default language | English (United States) `en-US`; translations Russian `ru-RU` and Ukrainian `uk` |
| Category | Tools |
| Contact e-mail | sza@ukr.net |
| Website | https://github.com/SerZhyAle/DeviceInfo_Android |
| Privacy policy | https://serzhyale.github.io/DeviceInfo_Android/privacy.html |
| Form factors | Phone and Wear OS (the watch package is uploaded to the same app) |
| Icon | `docs/play/icon-512.png` |
| Feature graphic | `docs/play/feature-graphic-1024x500.png` |

Both graphics are render targets of `tools/store/render-store-assets.ps1`; never edit them by hand. Screenshots come from a
real phone and a real watch and are uploaded from the device check of S0007.

## English (en-US)

**Title:** DeviceInfo

**Short description:** Full information about your phone and your Wear OS watch.

**Full description:**

DeviceInfo shows everything Android tells an app about the device it runs on - on your phone and on your Wear OS watch.

On the phone
- Grouped, collapsible sections: App, Battery, Cameras, Device, Display, Hardware, Locale, Media and audio, Memory, Network, OS, Sensors, Storage, System, Time and User. The groups stay the way you leave them.
- Battery: charge speed in mA and watts, power profile, nominal profile, estimated time to a full charge and estimated runtime left.
- Copy, save or share the whole report, or copy one section. Values that identify the device in a network - the signature hash, local addresses and mount paths - are hidden in the default copy.

On the watch
- Glanceable sections: Device, App, Memory, Storage, Phone connection, Health, Sensors, Wi-Fi and Environment.
- Send to phone hands the watch report to the paired phone, which stores it and shows a notification that opens or shares it.

Private by construction
- No account, no server, no telemetry, no ads. Neither app has the internet permission; what you see stays on the device unless you copy, save, share or send it yourself.
- Open source under the MIT License.

The apps speak English, Russian and Ukrainian.

**Release notes (first release):** The phone app shows the full information of the device in collapsible sections, with the battery charge speed and the estimated runtime. The watch app shows glanceable sections of the watch and sends its report to the phone.

## Russian (ru-RU)

**Название:** DeviceInfo

**Краткое описание:** Полная информация о вашем телефоне и часах Wear OS.

**Полное описание:**

DeviceInfo показывает всё, что Android сообщает приложению об устройстве, на котором оно работает, - на телефоне и на часах Wear OS.

На телефоне
- Сгруппированные сворачиваемые разделы: Приложение, Батарея, Камеры, Устройство, Экран, Оборудование, Локаль, Мультимедиа и аудио, Память, Сеть, ОС, Датчики, Хранилище, Система, Время и Пользователь. Группы остаются такими, какими вы их оставили.
- Батарея: скорость зарядки в мА и ваттах, профиль питания, номинальный профиль, оценка времени до полного заряда и оценка оставшейся работы.
- Копируйте, сохраняйте или отправляйте весь отчёт либо копируйте один раздел. Значения, по которым можно опознать устройство в сети, - хеш подписи, локальные адреса и пути монтирования, - скрыты в обычной копии.

На часах
- Разделы для беглого взгляда: Устройство, Приложение, Память, Хранилище, Телефон, Состояние, Датчики, Wi-Fi и Окружение.
- «Отправить на телефон» передаёт отчёт часов на сопряжённый телефон, который сохраняет его и показывает уведомление, открывающее отчёт или позволяющее поделиться им.

Приватность по построению
- Ни учётной записи, ни сервера, ни телеметрии, ни рекламы. У приложений нет разрешения на доступ к интернету; показанное остаётся на устройстве, пока вы сами не скопируете, не сохраните, не отправите это.
- Открытый исходный код по лицензии MIT.

Приложения говорят по-английски, по-русски и по-украински.

**Что нового (первый выпуск):** Приложение на телефоне показывает полную информацию об устройстве в сворачиваемых разделах, со скоростью зарядки батареи и оценкой оставшейся работы. Приложение на часах показывает разделы часов для беглого взгляда и отправляет их отчёт на телефон.

## Ukrainian (uk)

**Назва:** DeviceInfo

**Короткий опис:** Повна інформація про ваш телефон і годинник Wear OS.

**Повний опис:**

DeviceInfo показує все, що Android повідомляє застосунку про пристрій, на якому він працює, - на телефоні та на годиннику Wear OS.

На телефоні
- Згруповані розділи, що згортаються: Застосунок, Батарея, Камери, Пристрій, Екран, Обладнання, Локаль, Мультимедіа та аудіо, Пам'ять, Мережа, ОС, Датчики, Сховище, Система, Час і Користувач. Групи лишаються такими, якими ви їх залишили.
- Батарея: швидкість заряджання в мА та ватах, профіль живлення, номінальний профіль, оцінка часу до повного заряду й оцінка залишку роботи.
- Копіюйте, зберігайте або надсилайте весь звіт чи копіюйте один розділ. Значення, за якими можна впізнати пристрій у мережі, - хеш підпису, локальні адреси й шляхи монтування, - приховані у звичайній копії.

На годиннику
- Розділи для побіжного погляду: Пристрій, Програма, Пам'ять, Сховище, Телефон, Стан, Датчики, Wi-Fi і Оточення.
- «Надіслати на телефон» передає звіт годинника на спарений телефон, який зберігає його й показує сповіщення, що відкриває звіт або дає змогу поділитися ним.

Приватність за побудовою
- Жодного облікового запису, сервера, телеметрії чи реклами. Застосунки не мають дозволу на доступ до інтернету; показане лишається на пристрої, доки ви самі не скопіюєте, не збережете, не надішлете це.
- Відкритий початковий код за ліцензією MIT.

Застосунки розмовляють англійською, російською й українською.

**Що нового (перший випуск):** Застосунок на телефоні показує повну інформацію про пристрій у розділах, що згортаються, зі швидкістю заряджання батареї та оцінкою залишку роботи. Застосунок на годиннику показує розділи годинника для побіжного погляду й надсилає їхній звіт на телефон.
