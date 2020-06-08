
Функция ПолучитьСтрокуСоединенияПоСтруктуреПараметров(Знач СтруктураПараметровБазыДанных)
	
	СтрокаСоединения = "";
	
	Если СтруктураПараметровБазыДанных.ФайловаяБаза=Истина Тогда
		СтрокаСоединения = СтрокаСоединения+" /F """+СтруктураПараметровБазыДанных.СтрокаПодключенияКИБ+"""";
	Иначе
		СтрокаСоединения = СтрокаСоединения+" /S """+СтруктураПараметровБазыДанных.СтрокаПодключенияКИБ+"""";
	КонецЕсли;
	Если ЗначениеЗаполнено(СтруктураПараметровБазыДанных.Пользователь1С) Тогда
		СтрокаСоединения = СтрокаСоединения+" /N"""+СтруктураПараметровБазыДанных.Пользователь1С+"""";
		Если ЗначениеЗаполнено(СтруктураПараметровБазыДанных.Пользователь1С) И ЗначениеЗаполнено(СтруктураПараметровБазыДанных.Пароль1С) Тогда
			СтрокаСоединения = СтрокаСоединения+" /P"""+СтруктураПараметровБазыДанных.Пароль1С+"""";
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураПараметровБазыДанных.ДопПараметрыКоманднойСтроки) Тогда
		СтрокаСоединения = СтрокаСоединения + " "+СтруктураПараметровБазыДанных.ДопПараметрыКоманднойСтроки;
	КонецЕсли;

	Возврат СтрокаСоединения;
	
КонецФункции

Функция ПолучитьПараметрПодключенияПоТипуДанных(Знач ЗначениеПараметра,Знач ИмяПараметра)
	
	ТекстПредставления = Строка(ЗначениеПараметра);
	Если ТипЗнч(ЗначениеПараметра)=Тип("СправочникСсылка.Базы1С") Тогда
		ТекстПредставления = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ЗначениеПараметра,ИмяПараметра);	
	ИначеЕсли ТипЗнч(ЗначениеПараметра)=Тип("СправочникСсылка.ТестируемыеКлиенты") Тогда
		База1С = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ЗначениеПараметра,"База1С");
		ТекстПредставления = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База1С,ИмяПараметра);
	КонецЕсли;
	
	Возврат ТекстПредставления;
	
КонецФункции

Функция ПолучитьСоответствиеНастроекПользователя(Знач Пользователь, Знач ТекущееРабочееМесто) Экспорт
	
	СоответствиеНастроекПользователя = новый Соответствие();
	
	// получаем данные
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	КлючиНастроек.Ссылка,
	|	КлючиНастроек.Наименование,
	|	КлючиНастроек.ИмяПредопределенныхДанных,
	|	КлючиНастроек.ИмяКлюча
	|ИЗ
	|	Справочник.КлючиНастроек КАК КлючиНастроек
	|ГДЕ
	|	НЕ КлючиНастроек.ПометкаУдаления
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Т.Пользователь,
	|	Т.РабочееМесто,
	|	Т.КлючНастройки,
	|	Т.КлючНастройки.ИмяКлюча как ИмяКлюча,
	|	Т.ЗначениеНастройки
	|ИЗ
	|	РегистрСведений.НастройкиРаботыПользователяНаРабочемМесте КАК Т
	|ГДЕ
	|	Т.Пользователь = &Пользователь
	|	И Т.РабочееМесто = &РабочееМесто";
	Запрос.УстановитьПараметр("РабочееМесто",ТекущееРабочееМесто);
	Запрос.УстановитьПараметр("Пользователь",Пользователь);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	Выборка = РезультатЗапроса[0].Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СоответствиеНастроекПользователя.Вставить(Выборка.ИмяКлюча,Неопределено);
	КонецЦикла;
	
	
	Выборка = РезультатЗапроса[1].Выбрать();
	Пока Выборка.Следующий() Цикл
		СоответствиеНастроекПользователя.Вставить(Выборка.ИмяКлюча,Выборка.ЗначениеНастройки);
	КонецЦикла;
	
	// сообщим, что могут быть проблемы
	Если Выборка.Количество()=0 Тогда
		ЗаписьЖурналаРегистрации("СценарноеТестированиеСервер.ПолучитьСоответствиеНастроекПользователя",УровеньЖурналаРегистрации.Предупреждение,Неопределено,Неопределено,"Не указаны настройки пользователя '"+Строка(Пользователь)+"' рабочего места '"+Строка(ТекущееРабочееМесто)+"' по умолчанию. Укажите для корректной работы некоторых функций!");
	КонецЕсли;
	
	Возврат СоответствиеНастроекПользователя;
	
КонецФункции

Функция ПолучитьПутьКФайлуСценария(Знач Тест, Знач ПутьКВременномуКаталогуФайлов="", Знач ПутьКаталогGIT="") Экспорт
	
	ПутьКФайлуСценария = "";
	СтруктураСвойствСценария = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Тест,"ПутьКФайлу,ОсновнойВариантХраненияСценария,АдресИнтернет,Ссылка");
	
	Если СтруктураСвойствСценария.ОсновнойВариантХраненияСценария=Перечисления.ВариантыХраненияСценариев.ВоВнешнемФайлеGIT Тогда 
		ПутьКФайлуСценария = ПутьКаталогGIT+"\"+СтруктураСвойствСценария.ПутьКФайлу;
	ИначеЕсли СтруктураСвойствСценария.ОсновнойВариантХраненияСценария=Перечисления.ВариантыХраненияСценариев.ВТекущейБазеДанных Тогда 
		ПутьКФайлуСценария = ПутьКВременномуКаталогуФайлов+"\"+Строка(СтруктураСвойствСценария.Ссылка.UUID())+".xml";
	ИначеЕсли СтруктураСвойствСценария.ОсновнойВариантХраненияСценария=Перечисления.ВариантыХраненияСценариев.ВоВнешнемФайле Тогда 
		ПутьКФайлуСценария = СтруктураСвойствСценария.ПутьКФайлу;
	КонецЕсли;
	
	Возврат ПутьКФайлуСценария;
	
КонецФункции 

Функция ПолучитьПутьККаталогуБиблиотекиСценариев(Знач Тест, Знач ПутьКВременномуКаталогуФайлов="", Знач ПутьКаталогGIT="")
	
	ПутьККаталогу = "";
	
	СтруктураСвойствСценария = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Тест,"ПутьККаталогуБиблиотекиСценариев,ОсновнойВариантХраненияСценария,Ссылка");
	
	Если СтруктураСвойствСценария.ОсновнойВариантХраненияСценария=Перечисления.ВариантыХраненияСценариев.ВоВнешнемФайлеGIT Тогда 
		ПутьКФайлуСценария = ПутьКаталогGIT+"\"+СтруктураСвойствСценария.ПутьККаталогуБиблиотекиСценариев;
	ИначеЕсли СтруктураСвойствСценария.ОсновнойВариантХраненияСценария=Перечисления.ВариантыХраненияСценариев.ВТекущейБазеДанных Тогда 
		ПутьКФайлуСценария = ПутьКВременномуКаталогуФайлов+"\"+СтруктураСвойствСценария.ПутьККаталогуБиблиотекиСценариев;
	ИначеЕсли СтруктураСвойствСценария.ОсновнойВариантХраненияСценария=Перечисления.ВариантыХраненияСценариев.ВоВнешнемФайле Тогда 
		ПутьКФайлуСценария = СтруктураСвойствСценария.ПутьККаталогуБиблиотекиСценариев;
	КонецЕсли;
	
	Возврат ПутьККаталогу;
КонецФункции

Функция ОбработатьСтрокуПоПараметрам(Знач ИсходнаяСтрока, Знач СтруктураПараметров) Экспорт
	
	//TODO: необходимо получить сначала набор настроек, а потом последовательно в приоритете их применить, таким образом мы сможем избежать пустых значений
	
	ОбработаннаяСтрока = ИсходнаяСтрока;
	
	// мега глобальные параметры
	ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,"%ТекущаяДата%",Строка(ТекущаяДата()));
	СтруктураТекущегоПользователя = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ПользователиКлиентСервер.ТекущийПользователь(),"Наименование,НаименованиеСокращенное");
	ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,"%ТекущийПользователь%",СтруктураТекущегоПользователя.Наименование);
	ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,"%ТекущийПользовательНаименованиеСокращенное%",СтруктураТекущегоПользователя.НаименованиеСокращенное);
	Попытка
		ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,"%ТекущееРабочееМесто%",Строка(ПользователиКлиентСервер.ТекущееРабочееМесто()));	
	Исключение
	КонецПопытки;
	
	// если последний номер проверки
	Если СтрНайти(ИсходнаяСтрока,"%НомерПоследнейПроверки%") Тогда
		Запрос = новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
		|	Проверки.Ссылка,
		|	Проверки.Код КАК Код
		|ИЗ
		|	Справочник.Проверки КАК Проверки
		|
		|УПОРЯДОЧИТЬ ПО
		|	Код УБЫВ";
		РезультатЗапроса = Запрос.Выполнить();
		Если НЕ РезультатЗапроса.Пустой() Тогда
			Выборка = РезультатЗапроса.Выбрать();
			Выборка.Следующий();
			ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,"%НомерПоследнейПроверки%",Выборка.Код);
		КонецЕсли;
	КонецЕсли;
	
	// если пришла проверка
	Если ТипЗнч(СтруктураПараметров)=Тип("Структура") И
		СтруктураПараметров.Свойство("Проверка") Тогда
		
		ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,"%НомерПроверки%",ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтруктураПараметров.Проверка,"Код"));
		
	КонецЕсли;	
	
	// если пришла проверка
	Если ТипЗнч(СтруктураПараметров)=Тип("Структура") И
		СтруктураПараметров.Свойство("Сборка") Тогда
		
		ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,"%НомерСборки%",ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтруктураПараметров.Сборка,"Код"));
		
	КонецЕсли;	
	
	// пробежимся по заданию владельцу
	Если ТипЗнч(СтруктураПараметров)=Тип("Структура") И
		СтруктураПараметров.Свойство("ЗаданиеВладелец") Тогда
		
		СоответствиеПеременныхЗначениям = ПолучитьСоответствиеПеременныхЗначениям(СтруктураПараметров.ЗаданиеВладелец);
		Для каждого стр из СоответствиеПеременныхЗначениям Цикл
			Если Найти(ОбработаннаяСтрока,стр.Ключ) Тогда
				Значение = стр.Значение; 
				Если ТипЗнч(Значение)=Тип("Число") Тогда
					Значение = СтрЗаменить(Строка(Значение),Символы.НПП,"");
				КонецЕсли;
				ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,стр.Ключ,Значение);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;	
	
	// если пришло действие
	Если ТипЗнч(СтруктураПараметров)=Тип("Структура") И
		СтруктураПараметров.Свойство("Владелец") Тогда
		
		СоответствиеПеременныхЗначениям = ПолучитьСоответствиеПеременныхЗначениям(СтруктураПараметров.Владелец);
		Для каждого стр из СоответствиеПеременныхЗначениям Цикл
			Если Найти(ОбработаннаяСтрока,стр.Ключ) Тогда
				Значение = стр.Значение; 
				Если ТипЗнч(Значение)=Тип("Число") Тогда
					Значение = СтрЗаменить(Строка(Значение),Символы.НПП,"");
				КонецЕсли;
				ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,стр.Ключ,Значение);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	
	// если пришло задание
	Если ТипЗнч(СтруктураПараметров)=Тип("Структура") И
		СтруктураПараметров.Свойство("Задание") Тогда
		
		СоответствиеПеременныхЗначениям = ПолучитьСоответствиеПеременныхЗначениям(СтруктураПараметров.Задание);
		Для каждого стр из СоответствиеПеременныхЗначениям Цикл
			Если Найти(ОбработаннаяСтрока,стр.Ключ) Тогда
				Значение = стр.Значение; 
				Если ТипЗнч(Значение)=Тип("Число") Тогда
					Значение = СтрЗаменить(Строка(Значение),Символы.НПП,"");
				КонецЕсли;
				ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,стр.Ключ,Значение);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;  	
	
	// если пришло действие
	Если ТипЗнч(СтруктураПараметров)=Тип("Структура") И
		СтруктураПараметров.Свойство("Действие") Тогда
		
		СоответствиеПеременныхЗначениям = ПолучитьСоответствиеПеременныхЗначениям(СтруктураПараметров.Действие);
		Для каждого стр из СоответствиеПеременныхЗначениям Цикл
			Если Найти(ОбработаннаяСтрока,стр.Ключ) Тогда
				Значение = стр.Значение; 
				Если ТипЗнч(Значение)=Тип("Число") Тогда
					Значение = СтрЗаменить(Строка(Значение),Символы.НПП,"");
				КонецЕсли;
				ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,стр.Ключ,Значение);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	
	// в завершении подставим ГЛОБАВЛЬНЫЕ НАСТРОЙКИ ПО УМОЛЧАНИЮ
	// заменим на глобальные параметры настроек текущего пользователя
	Попытка
		СоответсвиеНастроек = ПолучитьСоответствиеНастроекПользователя(ПользователиКлиентСервер.ТекущийПользователь(),ПараметрыСеанса.ТекущееРабочееМесто);
	Исключение
		СоответсвиеНастроек = ПолучитьСоответствиеНастроекПользователя(ПользователиКлиентСервер.ТекущийПользователь(),ПараметрыСеанса.ТекущийРабочийСервер);
	КонецПопытки;
	
	Для каждого стр из СоответсвиеНастроек Цикл
		Если стр.Значение<>Неопределено Тогда
			ОбработаннаяСтрока = СтрЗаменить(ОбработаннаяСтрока,стр.Ключ,стр.Значение);
		КонецЕсли;
	КонецЦикла;	
	
	Возврат ОбработаннаяСтрока;
	
КонецФункции

Функция ПолучитьСтрокуСоединенияПоТипуДанных(Знач ЗначениеПараметра,Знач ТолькоСтрокаИБ=Ложь) Экспорт
	
	ТекстПредставления = Строка(ЗначениеПараметра);
	
	Если ТипЗнч(ЗначениеПараметра)=Тип("СправочникСсылка.Базы1С") Тогда
		
		СтруктураПараметровБазыДанных = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ЗначениеПараметра,"ФайловаяБаза,СтрокаПодключенияКИБ,ДопПараметрыКоманднойСтроки,Пароль1С,Пользователь1С");
		
		Если ТолькоСтрокаИБ=Истина Тогда
			ТекстПредставления = СтруктураПараметровБазыДанных.СтрокаПодключенияКИБ;
		Иначе
			СтрокаСоединенияМенеджера = ПолучитьСтрокуСоединенияПоСтруктуреПараметров(СтруктураПараметровБазыДанных);				
			ТекстПредставления = СтрокаСоединенияМенеджера;
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(ЗначениеПараметра)=Тип("СправочникСсылка.ТестируемыеКлиенты") Тогда
		
		СтруктураТестируемогоКлиента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ЗначениеПараметра,"База1С");
		Если НЕ ЗначениеЗаполнено(СтруктураТестируемогоКлиента.База1С) Тогда
			СтруктураТестируемогоКлиента.База1С = Справочники.Базы1С.ПустаяСсылка();
		КонецЕсли;
		СтруктураПараметровБазыДанных = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтруктураТестируемогоКлиента.База1С,"ФайловаяБаза,СтрокаПодключенияКИБ,ДопПараметрыКоманднойСтроки,Пароль1С,Пользователь1С");
		
		Если ТолькоСтрокаИБ=Истина Тогда
			ТекстПредставления = СтруктураПараметровБазыДанных.СтрокаПодключенияКИБ;
		Иначе
			СтрокаСоединенияМенеджера = ПолучитьСтрокуСоединенияПоСтруктуреПараметров(СтруктураПараметровБазыДанных);				
			ТекстПредставления = СтрокаСоединенияМенеджера;
		КонецЕсли;
		
	КонецЕсли;	
	
	
	Возврат ТекстПредставления;
	
КонецФункции

Функция ПолучитьСоответствиеПеременныхЗначениям(Знач Владелец) Экспорт
	
	СоответствиеВозврата = новый Соответствие;
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ПеременныеЗаданий.Задание КАК Владелец,
	|	ПеременныеЗаданий.ИмяПеременной КАК ИмяПеременной,
	|	ПеременныеЗаданий.НомерАргумента,
	|	ПеременныеЗаданий.ЗначениеПеременной,
	|	ПеременныеЗаданий.ИмяРеквизита,
	|	ПеременныеЗаданий.ИмяФункции КАК ИмяФункции,
	|	ПеременныеЗаданий.ИспользоватьФункцию
	|ИЗ
	|	РегистрСведений.ПеременныеЗаданий КАК ПеременныеЗаданий
	|ГДЕ
	|	ПеременныеЗаданий.Задание = &Владелец
	|	И ПеременныеЗаданий.ЭтоПараметрНастройки = ЛОЖЬ
	|ИТОГИ ПО
	|	ИмяПеременной";
	Запрос.УстановитьПараметр("Владелец",Владелец);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ВыборкаИерархия = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаИерархия.Следующий() Цикл
			
			Выборка = ВыборкаИерархия.Выбрать();
			
			ЗначениеПеременной = Неопределено;
			ИмяПеременной = "";
			ИмяРеквизита = "";
			МассивАргументов = новый Массив;
			ИспользоватьФункцию = Ложь;
			ИмяФункции = "";
			
			Пока Выборка.Следующий() Цикл
				
				ИмяПеременной = Выборка.ИмяПеременной;				
				ИмяРеквизита = Выборка.ИмяРеквизита;
				ИспользоватьФункцию = Выборка.ИспользоватьФункцию;
				ИмяФункции = Выборка.ИмяФункции;
				
				Если ЗначениеЗаполнено(ИмяРеквизита) Тогда
					Попытка
						ЗначениеПеременной = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.ЗначениеПеременной,ИмяРеквизита);
					Исключение
					    ТекстОшибки = ОписаниеОшибки();
						Сообщить(ТекстОшибки);
						ЗаписьЖурналаРегистрации("СценарноеТестированиеСервер.ПолучитьСоответствиеПеременныхЗначениям",УровеньЖурналаРегистрации.Ошибка,Неопределено,Неопределено,ТекстОшибки);
					КонецПопытки;
				Иначе
					ЗначениеПеременной = Выборка.ЗначениеПеременной;
				КонецЕсли;
				
				МассивАргументов.Добавить(ЗначениеПеременной);
				
			КонецЦикла;
			
			// вставляем данные в массив соответсвия
			ЗначениеПеременной = ПолучитьЗначениеФункции(ИмяФункции,МассивАргументов);
			СоответствиеВозврата.Вставить(ИмяПеременной,ЗначениеПеременной);		
			
		КонецЦикла;
	КонецЕсли;
	
	
	Возврат СоответствиеВозврата;
	
КонецФункции

Функция ПолучитьЗначениеФункции(ИмяФункции,МассивАргументов)
	
	ЗначениеПеременной = Неопределено;
	
	ВрегИмяФункции = Врег(ИмяФункции);
	
	Если ВрегИмяФункции=Врег("СтрокаСоединения") Тогда
		Если МассивАргументов.Количество()=1 Тогда
			ЗначениеПеременной = ПолучитьСтрокуСоединенияПоТипуДанных(МассивАргументов[0]);
		КонецЕсли;
	ИначеЕсли ВрегИмяФункции=Врег("СтрокаСоединенияИБ") Тогда
		Если МассивАргументов.Количество()=1 Тогда
			ЗначениеПеременной = ПолучитьСтрокуСоединенияПоТипуДанных(МассивАргументов[0],Истина);
		КонецЕсли;		
	ИначеЕсли ВрегИмяФункции=Врег("ИмяПользователя1С") Тогда
		Если МассивАргументов.Количество()=1 Тогда
			ЗначениеПеременной = ПолучитьПараметрПодключенияПоТипуДанных(МассивАргументов[0],"Пользователь1С");
		КонецЕсли;			
	ИначеЕсли ВрегИмяФункции=Врег("ПарольПользователя1С") Тогда
		Если МассивАргументов.Количество()=1 Тогда
			ЗначениеПеременной = ПолучитьПараметрПодключенияПоТипуДанных(МассивАргументов[0],"Пароль1С");
		КонецЕсли;			
	ИначеЕсли ВрегИмяФункции=Врег("ПутьКФайлуТеста") Тогда
		Если МассивАргументов.Количество()=1 Тогда
			Если ТипЗнч(МассивАргументов[0])=Тип("СправочникСсылка.Тесты") Тогда
				ЗначениеПеременной = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(МассивАргументов[0],"ПутьКФайлу");
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли ВрегИмяФункции = Врег("ПутьККаталогуБиблиотекиСценариев") Тогда
		Если МассивАргументов.Количество()=1 Тогда
			Если ТипЗнч(МассивАргументов[0])=Тип("СправочникСсылка.Тесты") Тогда
				ЗначениеПеременной = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(МассивАргументов[0],"ПутьККаталогуБиблиотекиСценариев");
			КонецЕсли;
		КонецЕсли;		
	ИначеЕсли ВрегИмяФункции=Врег("ТекущийПользователь") Тогда
		ЗначениеПеременной = Строка(Пользователи.ТекущийПользователь());
	ИначеЕсли ВрегИмяФункции=Врег("УникальныйИдентификатор") Тогда
		ЗначениеПеременной = строка(новый УникальныйИдентификатор());
	Иначе // если пустое имя функции
		Если МассивАргументов.Количество()>0 Тогда
			ЗначениеПеременной = МассивАргументов[0];
		КонецЕсли;
	КонецЕсли;
	
	
	Возврат ЗначениеПеременной;
КонецФункции


#Область УдалениеУстаревшихСобытий


Процедура УдалениеУстаревшихСобытий() Экспорт
	
	СрокХранениСобытий = Константы.СрокХраненияСобытий.Получить();
	УдалениеУстаревшихПроверок(СрокХранениСобытий);
	УдалениеУстаревшихСборок(СрокХранениСобытий);
	
КонецПроцедуры

Процедура УдалениеУстаревшихПроверок(СрокХранениСобытий)
	
	// удаляем устаревшие или битые
	Запрос = новый Запрос;
	Запрос.Текст="ВЫБРАТЬ ПЕРВЫЕ 10
	|	Т.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Проверки КАК Т
	|ГДЕ
	|	Т.ПометкаУдаления
	|	ИЛИ &СрокХранениСобытий <> 0
	|	И РАЗНОСТЬДАТ(Т.ДатаНачала, &ТекущаяДата, День) > &СрокХранениСобытий
	|	ИЛИ Т.ВидСобытия = ЗНАЧЕНИЕ(Перечисление.ВариантыХраненияСобытий.ДляУдаления)
	|УПОРЯДОЧИТЬ ПО
	|	Т.ДатаНачала";
	
	Запрос.УстановитьПараметр("СрокХранениСобытий",СрокХранениСобытий );
	Запрос.УстановитьПараметр("ТекущаяДата",ТекущаяДата() );
	РезультатЗапроса = Запрос.Выполнить();
	
	//таблица проверки
	Если РезультатЗапроса.Пустой()Тогда
		Возврат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию();
		Попытка

			//связанные регистры сведений
			УдалитьРегистрСведенийЗамерыПоказателейПоПроверке(Выборка.Ссылка);
			УдалитьРегистрСведенийПеременныеЗаданийПоПроверке(Выборка.Ссылка);
			УдалитьРегистрСведенийПользовательскиеПеременныеЗаданийПоПроверке(Выборка.Ссылка);
				
			ПроверкаОбъект = Выборка.Ссылка.ПолучитьОбъект();
			ПроверкаОбъект.Удалить();
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			
			Если ТранзакцияАктивна() Тогда
				ОтменитьТранзакцию();
			КонецЕсли;
			ЗаписьЖурналаРегистрации("УдалениеУстаревшихПроверок",УровеньЖурналаРегистрации.Ошибка,Метаданные.Справочники.Проверки,Выборка.Ссылка,ОписаниеОшибки());
			
		КонецПопытки;
		
	КонецЦикла;	
	 
КонецПроцедуры


Процедура УдалитьРегистрСведенийЗамерыПоказателейПоПроверке(ПроверкаСсылка)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.ЗамерыПоказателей ГДЕ Проверка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", ПроверкаСсылка);
	Если Запрос.Выполнить().Пустой() Тогда
		Возврат;
	КонецЕсли;	
	НЗ = РегистрыСведений.ЗамерыПоказателей.СоздатьНаборЗаписей();
	НЗ.Отбор.Проверка.Установить(ПроверкаСсылка);
	НЗ.Записать();
КонецПроцедуры

Процедура УдалитьРегистрСведенийПеременныеЗаданийПоПроверке(ПроверкаСсылка)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.ПеременныеЗаданий ГДЕ Ключ = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", ПроверкаСсылка);
	Если Запрос.Выполнить().Пустой() Тогда
		Возврат;
	КонецЕсли;	
	НЗ = РегистрыСведений.ПеременныеЗаданий.СоздатьНаборЗаписей();
	НЗ.Отбор.Ключ.Установить(ПроверкаСсылка);
	НЗ.Записать();
КонецПроцедуры

Процедура УдалитьРегистрСведенийПользовательскиеПеременныеЗаданийПоПроверке(ПроверкаСсылка)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.ПользовательскиеПеременныеЗаданий ГДЕ Ключ = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", ПроверкаСсылка);
	Если Запрос.Выполнить().Пустой() Тогда
		Возврат;
	КонецЕсли;	
	НЗ = РегистрыСведений.ПользовательскиеПеременныеЗаданий.СоздатьНаборЗаписей();
	НЗ.Отбор.Ключ.Установить(ПроверкаСсылка);
	НЗ.Записать();
КонецПроцедуры

Процедура УдалениеУстаревшихСборок(СрокХранениСобытий)
	
	// удаляем устаревшие или битые
	Запрос = новый Запрос;
	Запрос.Текст="ВЫБРАТЬ ПЕРВЫЕ 1000
	|	Т.Ссылка
	|ИЗ
	|	Справочник.Сборки КАК Т
	|ГДЕ
	|	Т.ПометкаУдаления
	|	ИЛИ &СрокХранениСобытий <> 0
	|	И РАЗНОСТЬДАТ(Т.ДатаНачала, &ТекущаяДата, День) > &СрокХранениСобытий
	|УПОРЯДОЧИТЬ ПО
	|	Т.ДатаНачала";
	
	Запрос.УстановитьПараметр("СрокХранениСобытий",СрокХранениСобытий );
	Запрос.УстановитьПараметр("ТекущаяДата",ТекущаяДата() );
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой()Тогда
		Возврат;
	КонецЕсли;
	 
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию();
		Попытка
			
			ПроверкаОбъект = Выборка.Ссылка.ПолучитьОбъект();
			ПроверкаОбъект.Удалить();
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			
			Если ТранзакцияАктивна() Тогда
				ОтменитьТранзакцию();
			КонецЕсли;
			ЗаписьЖурналаРегистрации("УдалениеУстаревшихСборок",УровеньЖурналаРегистрации.Ошибка,Метаданные.Справочники.Проверки,Выборка.Ссылка,ОписаниеОшибки());
			
		КонецПопытки;
		
	КонецЦикла;	
	 
КонецПроцедуры
#КонецОбласти