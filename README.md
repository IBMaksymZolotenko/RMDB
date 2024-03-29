# RMDB Project
Проект бази даних для обслуговування скорингових карт та тих складових процесу прийняття рішень, які стосуються ДпУР.

Основні цілі БД:
  * максимально обмежити доступ до інформації щодо скорингових параметрів та карт, забезпечити доступ до неї тільки відповідним працівникам ДпУР;
  * виокремити процес налаштування скорингових параметрів та карт з процесу прийняття рішення - зробити його більш незалежним від втручання з боку IT та максимально зав'язати на ДпУР.

## Основні схеми БД
Весь функціонал <span style="color:#ff3f05">БД</span> розбитий на схеми. Кожна схема - це незалежний від інших набір сутностей, інструментів для роботи з ними та інтерфейс для взаємодії з зовнішнім по відношенню до схеми середовищем.

### Schema::Scoring
Містить функціонал для роботи зі скоринговими картами.

#### Елементи схеми
| ТИП | НАЗВА | ОПИС |
|:-----------|:-----------------------------------|:-----------|
| Table | <a href="#ActivityField">ActivityField</a> | Сфера діяльності |
| Table | <a href="#ActivityFieldHistory">ActivityFieldHistory</a> | Історія зміни записів у таблиці ActivityField |
| Proc | sp_Calc_ScoreParams | Розрахунок скорингових параметрів |
| Proc | sp_ActivityField_ins | Додає запис у ActivityField |
| Proc | sp_ActivityField_upd | Оновлює запис у ActivityField |
| Proc | sp_ActivityField_del | Видаляє запис з ActivityField |

---

#### <span id = "ActivityField"/>ActivityField

Нові записи додаються Устіновим В. та Сорочинським О. Вони також розмічають поля GROUP_FIELD_OF_ACTIVITY та GROUP_POSITION.

| НАЗВА | ОПИС | ТИП ДАНИХ |
|:-----------------------------------|:-----------|:-----------|
| ID | Унікальний ідетнифікатор запису | INT |
| POSITION | Посада | NVARCHAR(200) |
| FIELD_OF_ACTIVITY | Сфера діяльності | NVARCHAR(200) |
| DESCRIPTION | Опис | NVARCHAR(MAX) |
| GROUP_FIELD_OF_ACTIVITY | Сфера діяльності, узагальнена назва (визначається ДпУР) | NVARCHAR(200) |
| GROUP_POSITION | Посада, узагальнена назва (визначається ДпУР) | NVARCHAR(200) |
| *службові поля* | ... | ... |

#### <span id = "ActivityFieldHistory"/>ActivityFieldHistory
| НАЗВА | ОПИС | ТИП ДАНИХ |
|:-----------------------------------|:-----------|:-----------|
| ID | Унікальний ідетнифікатор запису | INT |
| ACTIVITYFIELDID | ID з ActivityField | INT |
| *інші поля подібні до ActivityField* | ... | ... |
| HCREATED | Дата створення запису у ActivityFieldHistory | DATETIME2(7) |

---
