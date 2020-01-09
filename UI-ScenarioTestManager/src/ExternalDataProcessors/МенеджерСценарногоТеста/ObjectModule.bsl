 
Функция СведенияОВнешнейОбработке() Экспорт
	    
	МассивНазначений = Новый Массив;
	
	ПараметрыРегистрации = Новый Структура;
	ПараметрыРегистрации.Вставить("Вид", "ДополнительнаяОбработка");
	ПараметрыРегистрации.Вставить("Назначение", МассивНазначений);
	ПараметрыРегистрации.Вставить("Наименование", "Менеджер сценарного теста");
	ПараметрыРегистрации.Вставить("Версия", "2019.01.06");
	ПараметрыРегистрации.Вставить("БезопасныйРежим", Ложь);
	ПараметрыРегистрации.Вставить("Информация", ПолучитьИнформацию());
	ПараметрыРегистрации.Вставить("ВерсияБСП", "1.2.1.4");
	ТаблицаКоманд = ПолучитьТаблицуКоманд();
	ДобавитьКоманду(ТаблицаКоманд,
	                "Менеджер сценарного теста",
					"МенеджерСценарногоТеста",
					"ОткрытиеФормы",
					Истина,
					);
	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Функция ПолучитьТаблицуКоманд()
	
	Команды = Новый ТаблицаЗначений;
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
	
	Возврат Команды;
	
КонецФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование, ПоказыватьОповещение = Ложь, Модификатор = "")
	
	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;
	
КонецПроцедуры

Функция ПолучитьИнформацию()
	
	ТекстИнфо = "";
	ТекстИнфо = "Менеджер сценарного теста. Используется в составе конфигурации Тестирования.
	| 
	| Предназначен для создания/редактирования/запуска сценариев. 
	| Есть встроенный редактор сценариев.
	| Есть возможность записи и преобразования действий.
	| Есть возможность запуска с обработкой командной строки.
	| Есть возможность работы с внешними API: Selenium и Microsoft Automation UI.
	|
	|
	| Проект по адресу: https://github.com/ivanov660/TestingTool-3
	| Проект по адресу: https://testingtool.ru
	|";
	
	Возврат ТекстИнфо;
КонецФункции