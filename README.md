# RMDB Project
Проект бази даних для обслуговування скорингових карт та тих складових процесу прийняття рішень, які стосуються ДпУР.

Основні цілі БД:
  * максимально обмежити доступ до інформації щодо скорингових параметрів та карт, забезпечити доступ до неї тільки відповідним працівникам ДпУР;
  * виокремити процес налаштування скорингових параметрів та карт з процесу прийняття рішення - зробити його більш незалежним від втручання з боку IT та максимально зав'язати на ДпУР.

## Основні схеми БД
Весь функціонал <span style="color:#ff3f05">БД</span> розбитий на схеми. Кожна схема - це незалежний від інших набір сутностей, інструментів для роботи з ними та інтерфейс для взаємодії з зовнішнім по відношенню до схеми середовищем.

### Scoring
Містить функціонал для роботи зі скоринговими картами.

#### Елементи схеми
| ТИП | НАЗВА | ОПИС |
|:-----------|-----------------------------------|-----------|
| Table | <a href="#ActivityField">ActivityField</a> | Сфера діяльності |
| Table | ActivityFieldHistory | Історія зміни записів у таблиці ActivityField |
| Proc | sp_Calc_ScoreParams | Розрахунок скорингових параметрів |
| Proc | sp_ActivityField_ins | Додає запис у ActivityField |
| Proc | sp_ActivityField_upd | Оновлює запис у ActivityField |
| Proc | sp_ActivityField_del | Видаляє запис з ActivityField |

---

#### <span id = "ActivityField"/>ActivityField
| НАЗВА | ОПИС |
|-----------------------------------|-----------|
| ID | ID |
| POSITION | Посада |
| FIELD_OF_ACTIVITY | Сфера діяльності |
| DESCRIPTION | Опис |
