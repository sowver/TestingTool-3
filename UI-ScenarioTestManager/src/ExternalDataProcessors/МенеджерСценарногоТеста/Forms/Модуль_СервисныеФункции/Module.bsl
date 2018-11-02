&НаКлиенте
Перем RegExp;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Отказ = Истина; // форма не предназначена для открытия
КонецПроцедуры

&НаКлиенте
Функция ПолучитьПутьUrl(Знач АдресИнтернет, Знач НомерПорта) Экспорт
	
	СтруктураАдреса = СтруктураURI(АдресИнтернет);
	
	Если НЕ СтруктураАдреса.Порт=Неопределено Тогда
		ПутьUrl = АдресИнтернет;
	Иначе
		ПутьUrl = "http://localhost:"+Формат(НомерПорта,"ЧГ=;");
	КонецЕсли;
	
	Возврат ПутьUrl;
КонецФункции

&НаКлиенте
Функция ЗагрузитьФайлПоИнтернетАдресу(Знач ПолныйАдресРесурса,СохранятьВФайл=Ложь) Экспорт

	СтруктураОтвета = Новый Структура("ПутьКФайлу,КодСостояния,ТекстОшибки,ТелоСтрокой", "", 0, "");

	СтруктураURI = СтруктураURI(ПолныйАдресРесурса);

	HTTPСоединение = Новый HTTPСоединение(СтруктураURI.Хост, СтруктураURI.Порт);
	HTTPЗапрос = Новый HTTPЗапрос(СтруктураURI.ПутьНаСервере);
	
	Если СохранятьВФайл=Истина Тогда
		СтруктураОтвета.ПутьКФайлу = ПолучитьИмяВременногоФайла();
	КонецЕсли;

	Попытка
		Если СохранятьВФайл=Истина Тогда
			Результат = HTTPСоединение.Получить(HTTPЗапрос, СтруктураОтвета.ПутьКФайлу);
		Иначе
			Результат = HTTPСоединение.Получить(HTTPЗапрос);
		КонецЕсли;
	Исключение
	// исключение здесь говорит о том, что запрос не дошел до HTTP-Сервера
		СтруктураОтвета.ТекстОшибки = "Произошла сетевая ошибка!" + Символы.ПС
			+ ОписаниеОшибки();
		СообщитьОбОшибке("Модуль_ЗаписьЖурналаДействий.ЗагрузитьФайлПоИнтернетАдресу", СтруктураОтвета.ТекстОшибки);
		Возврат СтруктураОтвета;
	КонецПопытки;

	СтруктураОтвета.КодСостояния = Результат.КодСостояния;

	// Анализируем фатальные ошибки
	// В большинстве случаев нужно остановить работу и показать пользователю сообщение об ошибке,
	// включив в него HTTP-статус

	// Ошибки 4XX говорят о неправильном запросе - в широком смысле
	// Может быть неправильный адрес, ошибка аутентификации, плохой формат запроса
	// Подробнее смотри http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4
	Если Результат.КодСостояния >= 400 и Результат.КодСостояния < 500 Тогда
		СтруктураОтвета.ТекстОшибки = "Код статуса больше 4XX, ошибка запроса.  Код статуса: "
			+ Результат.КодСостояния;
		Возврат СтруктураОтвета;
	КонецЕсли;

	// Ошибки 5XX говорят о проблемах на сервере (возможно, прокси-сервер)
	// Это может быть программная ошибка, нехватка памяти, ошибка конфигурации и т.д.
	// Подробнее смотри http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.5
	Если Результат.КодСостояния >= 500 и Результат.КодСостояния < 600 Тогда
		СтруктураОтвета.ТекстОшибки = "Код статуса больше 5XX, ошибка сервера. Код статуса: "
			+ Результат.КодСостояния;
		Возврат СтруктураОтвета;
	КонецЕсли;

	// Обрабатываем перенаправление
	Если Результат.КодСостояния >= 300 и Результат.КодСостояния < 400 Тогда
	//Сообщить("Код статуса больше 3XX, Перенаправление. Код статуса: " + Результат.КодСостояния);
		Если Результат.КодСостояния = 302 Тогда
		//Сообщить("Код статуса 302, Постоянное перенаправление.");
			АдресРесурса = Результат.Заголовки.Получить("Location");
			Если АдресРесурса <> Неопределено Тогда
			//Сообщить("Выполняю запрос по новому адресу " + АдресРесурса);
				СтруктураОтвета = ЗагрузитьФайлПоИнтернетАдресу(АдресРесурса,СохранятьВФайл);
			Иначе
				СтруктураОтвета.ТекстОшибки = "Код статуса больше 3XX, Перенаправление. Код статуса: "
					+ Результат.КодСостояния + ". Сервер не сообщил адрес ресурса!";
				Возврат СтруктураОтвета;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	// Статусы 1XX и 2XX считаем хорошими
	Если Результат.КодСостояния < 300 Тогда
	КонецЕсли;
	
	Если НЕ СохранятьВФайл=Истина Тогда
		СтруктураОтвета.ТелоСтрокой = Результат.ПолучитьТелоКакСтроку();
	КонецЕсли; 

	Возврат СтруктураОтвета;

КонецФункции

&НаКлиенте
Функция СтруктураURI(Знач СтрокаURI) Экспорт

	СтрокаURI = СокрЛП(СтрокаURI);

	// схема
	Схема = "";
	Позиция = Найти(СтрокаURI, "://");
	Если Позиция > 0 Тогда
		Схема = НРег(Лев(СтрокаURI, Позиция - 1));
		СтрокаURI = Сред(СтрокаURI, Позиция + 3);
	КонецЕсли;

	// строка соединения и путь на сервере
	СтрокаСоединения = СтрокаURI;
	ПутьНаСервере = "";
	Позиция = Найти(СтрокаСоединения, "/");
	Если Позиция > 0 Тогда
		ПутьНаСервере = Сред(СтрокаСоединения, Позиция + 1);
		СтрокаСоединения = Лев(СтрокаСоединения, Позиция - 1);
	КонецЕсли;

	// информация пользователя и имя сервера
	СтрокаАвторизации = "";
	ИмяСервера = СтрокаСоединения;
	Позиция = Найти(СтрокаСоединения, "@");
	Если Позиция > 0 Тогда
		СтрокаАвторизации = Лев(СтрокаСоединения, Позиция - 1);
		ИмяСервера = Сред(СтрокаСоединения, Позиция + 1);
	КонецЕсли;

	// логин и пароль
	Логин = СтрокаАвторизации;
	Пароль = "";
	Позиция = Найти(СтрокаАвторизации, ":");
	Если Позиция > 0 Тогда
		Логин = Лев(СтрокаАвторизации, Позиция - 1);
		Пароль = Сред(СтрокаАвторизации, Позиция + 1);
	КонецЕсли;

	// хост и порт
	Хост = ИмяСервера;
	Порт = "";
	Позиция = Найти(ИмяСервера, ":");
	Если Позиция > 0 Тогда
		Хост = Лев(ИмяСервера, Позиция - 1);
		Порт = Сред(ИмяСервера, Позиция + 1);
	КонецЕсли;

	Результат = Новый Структура;
	Результат.Вставить("Схема", Схема);
	Результат.Вставить("Логин", Логин);
	Результат.Вставить("Пароль", Пароль);
	Результат.Вставить("ИмяСервера", ИмяСервера);
	Результат.Вставить("Хост", Хост);
	Результат.Вставить("Порт", ?(Порт <> "", Число(Порт), Неопределено));
	Результат.Вставить("ПутьНаСервере", ПутьНаСервере);

	Возврат Результат;

КонецФункции

&НаСервереБезКонтекста
Процедура СообщитьОбОшибке(ИмяФункции, Сообщение) Экспорт

	ЗаписьЖурналаРегистрации("МенеджерСценарногоТеста", УровеньЖурналаРегистрации.Ошибка, Неопределено, Неопределено, ИмяФункции
		+ Символы.ПС + Сообщение);

КонецПроцедуры

&НаКлиенте
Функция ОбработкаJSON(Знач ТекстJSON,Вариант="ПоУмолчанию") Экспорт

	Результат = Новый Структура;

	Если Вариант="Вручную" Тогда
		Результат = ОбработкаJSONВручную(ТекстJSON);
	ИначеЕсли Вариант="ПоУмолчанию" или Вариант="" Тогда
		Результат = ДанныеИзJSONСтроки(ТекстJSON);
	КонецЕсли;

	Возврат Результат;

КонецФункции


&НаКлиенте
Функция ОбработкаJSONВручную(Знач ТекстJSON) Экспорт

	Результат = Новый Структура;
	//ТекстJSON = СтрЗаменить(ТекстJSON, """", """"); // заменим последовательность " на "
	//ТекстJSON = СтрЗаменить(ТекстJSON, """", ""); // а теперь удалим все кавычки
	Если Лев(ТекстJSON, 1) = "{" Тогда // начало структуры
		ЗаполнитьДанныеИзОтветаJSON(Результат, ТекстJSON, "Структура");

	ИначеЕсли Лев(ТекстJSON, 1) = "[" Тогда //начало массива
		МассивДанных = Новый Массив;
		ЗаполнитьДанныеИзОтветаJSON(МассивДанных, ТекстJSON, "Массив");
		Результат.Вставить("Значение", МассивДанных);

	КонецЕсли;

	Возврат Результат;

КонецФункции

&НаКлиенте
Функция ДанныеИзJSONСтроки( Строка , Знач ИменаСвойствСоЗначениямиДата = "") Экспорт
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку( Строка );
	Данные = ПрочитатьJSON( ЧтениеJSON ,, ИменаСвойствСоЗначениямиДата );
	ЧтениеJSON.Закрыть();
	
	Возврат Данные;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьДанныеИзОтветаJSON(Результат, ТекстJSON, ТипДанных) Экспорт

	ТекстJSON = СокрЛП(Сред(ТекстJSON, 2)); // удалим открывающий символ структуры(массива)
	НомерЗначения = 0;

	Пока ТекстJSON <> "" Цикл

		ПервыйСимвол = Лев(ТекстJSON, 1);

		Если ПервыйСимвол = "{" Тогда //вложенная структура
			Значение = Новый Структура;
			ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Структура");

			Если ТипДанных = "Структура" Тогда

				Результат.Вставить("Значение"
					+ ?(НомерЗначения = 0, "", НомерЗначения), Значение);
				НомерЗначения = НомерЗначения + 1;

			ИначеЕсли ТипДанных = "Массив" Тогда

				Результат.Добавить(Значение);

			КонецЕсли;

		ИначеЕсли ПервыйСимвол = "[" Тогда //вложенный массив
			Значение = Новый Массив;
			ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Массив");

			Если ТипДанных = "Структура" Тогда

				Результат.Вставить("Значение"
					+ ?(НомерЗначения = 0, "", НомерЗначения), Значение);
				НомерЗначения = НомерЗначения + 1;

			Иначе

				Результат.Добавить(Значение);

			КонецЕсли;

		ИначеЕсли ПервыйСимвол = "}" И ТипДанных = "Структура" Тогда //структура закончилась
			ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));

			Если Лев(ТекстJSON, 1) = "," Тогда

				ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));

			КонецЕсли;

			Возврат;

		ИначеЕсли ПервыйСимвол = "]" И ТипДанных = "Массив" Тогда //массив закончился
			ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));

			Если Лев(ТекстJSON, 1) = "," Тогда

				ТекстJSON = СокрЛП(Сред(ТекстJSON, 2));

			КонецЕсли;

			Возврат;

		Иначе

			Если ТипДанных = "Структура" Тогда

				ПервыйКавычка = Ложь;

				Если Лев(ТекстJSON, 1) = """" Тогда

					ПервыйКавычка = Истина;

				КонецЕсли;

				Поз = Найти(ТекстJSON, ":");

				Если Поз = 0 Тогда

					Прервать;

				КонецЕсли;

				ПредпоследнийКавычка = Ложь;

				Если Сред(ТекстJSON, Поз - 1, 1) = """" Тогда

					ПредпоследнийКавычка = Истина;

				КонецЕсли;


				ИмяЗначения = СокрЛП(Лев(ТекстJSON, Поз - 1));
				ИмяЗначения = СтрЗаменить(ИмяЗначения, """", "");

				ТекстJSON = СокрЛП(Сред(ТекстJSON, Поз + 1));

				Если Лев(ТекстJSON, 1) = "{" Тогда //значение является структурой
					Значение = Новый Структура;
					ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Структура");

				ИначеЕсли Лев(ТекстJSON, 1) = "[" Тогда //значение является массивом
					Значение = Новый Массив;
					ЗаполнитьДанныеИзОтветаJSON(Значение, ТекстJSON, "Массив");

				Иначе // обычное значение
					ПервыйКавычка = Ложь;
					ПредпоследнийКавычка = Ложь;
					Поз = 0;
					Для Сч = 1 По СтрДлина(ТекстJSON) Цикл
						Символ = Сред(ТекстJSON, Сч, 1);

						Если Символ = """" Тогда

							Если ПервыйКавычка Тогда

								ПредпоследнийКавычка = Истина;

							Иначе
								ПервыйКавычка = Истина;

							КонецЕсли;

						КонецЕсли;

						Если (Символ = "," И ((ПервыйКавычка И ПредпоследнийКавычка)
								Или (Не ПервыйКавычка И Не ПредпоследнийКавычка))) ИЛИ ((ПервыйКавычка
								И ПредпоследнийКавычка) И Символ = "]") ИЛИ Символ = "}" Тогда

							Поз = Сч;

							Прервать;

						КонецЕсли;

					КонецЦикла;

					ПредпоследнийКавычка = Ложь;

					Если Сред(ТекстJSON, Поз - 1, 1) = """" Тогда

						ПредпоследнийКавычка = Истина;

					КонецЕсли;

					Если Поз = 0 Тогда

						Значение = ТекстJSON;
						ТекстJSON = "";

					Иначе

						Значение = Лев(ТекстJSON, Поз - 1);
						Значение = СтрЗаменить(Значение, """", "");
						ТекстJSON = СокрЛП(Сред(ТекстJSON, Поз
							+ ?(Сред(ТекстJSON, Поз, 1) = ",", 1, 0)));

					КонецЕсли;

					Значение = СокрЛП(Значение);

				КонецЕсли;

				Результат.Вставить(ИмяЗначения, Значение);

			ИначеЕсли ТипДанных = "Массив" Тогда //обычное значение
				Поз = 0;

				Для Сч = 1 По СтрДлина(ТекстJSON) Цикл

					Символ = Сред(ТекстJSON, Сч, 1);

					Если Символ = "," ИЛИ Символ = "]" ИЛИ Символ = "}" Тогда

						Поз = Сч;
						Прервать;

					КонецЕсли;

				КонецЦикла;

				ПредпоследнийКавычка = Ложь;

				Если Сред(ТекстJSON, Поз - 1, 1) = """" Тогда

					ПредпоследнийКавычка = Истина;

				КонецЕсли;

				Если Поз = 0 Тогда

					Значение = ТекстJSON;
					ТекстJSON = "";

				Иначе

					Значение = Лев(ТекстJSON, Поз - 1);
					Значение = СтрЗаменить(Значение, """", "");
					ТекстJSON = СокрЛП(Сред(ТекстJSON, Поз
						+ ?(Сред(ТекстJSON, Поз, 1) = ",", 1, 0)));

				КонецЕсли;

				Значение = СокрЛП(Значение);

				Результат.Добавить(Значение);

			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Функция СравнитьСПредставлениемДанных(Знач УсловиеСравнения, ШаблонПроверки, ПроверяемыйТекст) Экспорт
	
	ОписаниеОшибки = "";
	Врег_УсловиеСравенения = СокрЛП(Врег(УсловиеСравнения)); 
	
	Если Врег_УсловиеСравенения="РАВНО" Тогда
		Если ШаблонПроверки <> ПроверяемыйТекст Тогда
			ОписаниеОшибки = "Ожидаемое значение:("+ШаблонПроверки+") <> Представление данных: ("+ПроверяемыйТекст+")";
		КонецЕсли;
	ИначеЕсли Врег_УсловиеСравенения="НЕРАВНО" Тогда
		Если ШаблонПроверки = ПроверяемыйТекст Тогда
			ОписаниеОшибки = "Ожидаемое значение:("+ШаблонПроверки+") = Представление данных: ("+ПроверяемыйТекст+")";
		КонецЕсли;
	ИначеЕсли Врег_УсловиеСравенения="ЗАПОЛНЕНО" Тогда
		Если НЕ ЗначениеЗаполнено(ПроверяемыйТекст) Тогда
			ОписаниеОшибки = "Значение НЕ ЗАПОЛНЕНО, а должно быть заполнено.";
		КонецЕсли;
	ИначеЕсли Врег_УсловиеСравенения="НЕЗАПОЛНЕНО" Тогда
		Если ЗначениеЗаполнено(ПроверяемыйТекст) Тогда
			ОписаниеОшибки = "Значение ЗАПОЛНЕНО Представление данных: ("+ПроверяемыйТекст+"), а не должно быть заполнено";
		КонецЕсли;
	ИначеЕсли Врег_УсловиеСравенения="СОДЕРЖИТ" Тогда
		Если НЕ Найти(ПроверяемыйТекст,ШаблонПроверки) Тогда
			ОписаниеОшибки = "Представление данных: ("+ПроверяемыйТекст+") не содержит Ожидаемое значение:("+ШаблонПроверки+"), а должно ";
		КонецЕсли;
	ИначеЕсли Врег_УсловиеСравенения="НЕСОДЕРЖИТ" Тогда
		Если Найти(ПроверяемыйТекст,ШаблонПроверки) Тогда
			ОписаниеОшибки = "Представление данных: ("+ПроверяемыйТекст+") содержит Ожидаемое значение:("+ШаблонПроверки+"), а не должно! ";
		КонецЕсли;
		
	ИначеЕсли Врег_УсловиеСравенения="REGEXP" Тогда
		Если НЕ RegExp_ПроверитьTest(ПроверяемыйТекст,ШаблонПроверки) Тогда
			ОписаниеОшибки = "REGEXP: Значение ("+ПроверяемыйТекст+") не прошла функция RegExp Test по Шаблону:("+ШаблонПроверки+")! ";
		КонецЕсли;				
	ИначеЕсли Врег_УсловиеСравенения="НЕREGEXP" Тогда
		Если RegExp_ПроверитьTest(ПроверяемыйТекст,ШаблонПроверки) Тогда
			ОписаниеОшибки = "НЕ REGEXP: Значение ("+ПроверяемыйТекст+") не прошла функция RegExp Test по Шаблону:("+ШаблонПроверки+")! ";
		КонецЕсли;				
	Иначе
		Если ШаблонПроверки <> ПроверяемыйТекст Тогда
			ОписаниеОшибки = "Ожидаемое значение:("+ШаблонПроверки+") <> Представление данных: ("+ПроверяемыйТекст+")";
		КонецЕсли;
	КонецЕсли;
	
	Возврат ОписаниеОшибки; 

КонецФункции


#Область RegExp

&НаКлиенте
Процедура RegExp_Инициализировать(Шаблон, ИскатьДоПервогоСовпадения = Истина, МногоСтрок = Истина, ИгнорироватьРегистр = Истина) Экспорт

    Если RegExp = Неопределено Тогда //Нужна инициализация
        RegExp = Новый COMОбъект("VBScript.RegExp");    // создаем объект для работы с регулярными выражениями
    КонецЕсли;

    //Заполняем данные
    RegExp.MultiLine = МногоСтрок;                  // истина — текст многострочный, ложь — одна строка
    RegExp.Global = Не ИскатьДоПервогоСовпадения;   // истина — поиск по всей строке, ложь — до первого совпадения
    RegExp.IgnoreCase = ИгнорироватьРегистр;        // истина — игнорировать регистр строки при поиске
    RegExp.Pattern = Шаблон;                        // шаблон (регулярное выражение)

КонецПроцедуры

&НаКлиенте
Функция RegExp_ПроверитьTest(ПроверяемыйТекст, Шаблон, ИскатьДоПервогоСовпадения = Истина, МногоСтрок = Истина, ИгнорироватьРегистр = Истина)
	
	СистемнаяИнформация = Новый СистемнаяИнформация();
	Если СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86 ИЛИ СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда
	Иначе
		ВызватьИсключение "Функция RegExp доступна на операционных системах Windows.";
	КонецЕсли;
	
	Попытка
		
		Если RegExp=Неопределено Тогда
			RegExp_Инициализировать(Шаблон,ИскатьДоПервогоСовпадения,МногоСтрок,ИгнорироватьРегистр);
		КонецЕсли;
		
		RegExp.Pattern = Шаблон;
		
		Если RegExp.Test(ПроверяемыйТекст) Тогда
			Возврат Истина;
		Иначе
			Возврат Ложь;
		КонецЕсли;
		
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		ВызватьИсключение "Произошла ошибка при работе RegExp:"+ТекстОшибки;
	КонецПопытки;
	
КонецФункции

#КонецОбласти
