// см. МодификацияКонфигурацииПереопределяемый.ПриСозданииНаСервере
//
Процедура ПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	
	// Для  простоты определения типа и имени объекта создана вспомогательная функция
	Результат = префикс_КлиентСервер.ПолучитьТипОбъектаСтрокойИИмяФормы(Форма.ИмяФормы);
	ТипОбъекта = Результат.ТипОбъекта;
	ИмяФормы = Результат.ИмяФормы;
	
	Если ТипОбъекта = "ЗаказКлиента" Тогда
		Если ИмяФормы = "ФормаДокумента" Тогда

		КонецЕсли;
	ИначеЕсли ТипОбъекта = "Номенклатура" Тогда	
		Если ИмяФормы = "ФормаЭлемента" Тогда
			ДобавитьНовыеРеквизитыВКарточкуНоменклатуры(Форма); 
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

// Функция добавляет реквизит/ы формы, возвращая созданные реквизиты
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения 
//  Реквизиты - Структура (если добавляем один реквизит) или Массив структур следующегго вида:
//   * Имя - Строка, содержит имя реквизита
//   * Тип - Строка типа, Тип или ОписаниеТипов
//   * Заголовок - необязательный элемент, Строка, содержит отображаемый текст реквизита
//  если заголовок не задан, то формируется функцией "ПолучитьЗаголовокПоИмени"
//   * Путь - необязательный элемент, Строка, содержит путь к реквизиту, не включая имя реквизита
//   * СохраняемыеДанные - необязательный элемент, Булево, если Истина - указывает, что это сохраняемый при записи реквизит, по умолчанию Ложь  
//
// Возвращаемое значение:
//  РеквизитФормы или Массив Реквизитов формы
//
Функция ДобавитьРеквизитыФормы(Форма, Реквизиты)

	НовыеРеквизиты = Новый Массив;
	
	Если ТипЗнч(Реквизиты) = Тип("Структура") Тогда
		Реквизит = Реквизиты;
		Реквизиты = Новый Массив;                                                  
		Реквизиты.Добавить(Реквизит);
	КонецЕсли;

	Для Каждого Реквизит Из Реквизиты Цикл
		
		Имя = Реквизит.Имя;
		Тип = Реквизит.Тип;
		Если ТипЗнч(Тип) = Тип("Строка") Тогда
			Тип = Новый ОписаниеТипов(Тип);
		ИначеЕсли ТипЗнч(Тип) = Тип("Тип") Тогда
			МассивТипов = Новый Массив;
			МассивТипов.Добавить(Тип);
       		Тип = Новый ОписаниеТипов(МассивТипов);
		КонецЕсли;	
		Путь = Неопределено; Заголовок = Неопределено; СохраняемыеДанные = Неопределено;
		Реквизит.Свойство("Путь", Путь);
		Реквизит.Свойство("Заголовок", Заголовок);
		Реквизит.Свойство("СохраняемыеДанные", СохраняемыеДанные);
		Если Путь = Неопределено Тогда
			Путь = "";
		КонецЕсли;
		Если Заголовок = Неопределено Тогда
			Заголовок = ПолучитьЗаголовокПоИмени(Имя);
		КонецЕсли;
		Если СохраняемыеДанные = Неопределено Тогда
			СохраняемыеДанные = Ложь;
		КонецЕсли;

		НовыйРеквизит = Новый РеквизитФормы(Имя, Тип, Путь, Заголовок, СохраняемыеДанные);
		НовыеРеквизиты.Добавить(НовыйРеквизит);
		
	КонецЦикла;
	
	Форма.ИзменитьРеквизиты(НовыеРеквизиты);
	
	Если НовыеРеквизиты.Количество() > 1 Тогда
		Возврат НовыеРеквизиты;
	Иначе
		Возврат НовыеРеквизиты[0];
	КонецЕсли;
	
КонецФункции

// Функция добавляет команду формы, возвращая созданную команду для дальнейшей модификации при необходимости
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  Имя - Строка, содержит имя команды
//  Действие - Строка, содержит имя процедуры обработчика команды,
//для действия по умолчанию см. МодификацияКонфигурацииКлиентПереопределяемый.ВыполнитьПереопределяемуюКоманду 
//
// Возвращаемое значение:
//  КомандыФормы
//
Функция ДобавитьКомандуФормы(Форма, Имя, Действие = "Подключаемый_ВыполнитьПереопределяемуюКоманду")
	
	Команда = Форма.Команды.Добавить(Имя);
	Команда.Заголовок = ПолучитьЗаголовокПоИмени(Имя);
	Команда.Действие = Действие;
	Возврат Команда	
	
КонецФункции

// Функция добавляет новый элемент типа ПолеФормы
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  ПутьКданным - Строка, содержит путь к реквизиту, с которым связан объект
//  Родитель - Элемент формы, родитель для добавляемого элемента, если не указан, то добавляется на верхний уровень
//  ЭлементПередКоторымВставить - Элемент формы или Число (номер элемента формы, нумерация начинается с 1), перед которым должен быть вставлен новый элемент
//Если не указан, то элемент будет вставлен в конец
//Указание числом места вставки полезно, например, когда элемент нужно вставить в самое начало группы, а второй элемент формы может добавляться программно
//  ВидПоля - ВидПоляФормы, по умолчанию ПолеВвода
//  Эталон - Элемент формы, свойства которого нужно скопировать, при этом уникальные свойства не копируются (см. переменную ИсключаемыеСвойства внутри функции) 
//
// Возвращаемое значение:
//  ПолеФормы
//
Функция ДобавитьПолеФормы(Форма, ПутьКданным, Родитель = Неопределено, ЭлементПередКоторымВставить = Неопределено, ВидПоля = Неопределено, Эталон = Неопределено)

	РеквизитСРодителем = ПолучитьРеквизит(Форма, ПутьКданным);
	Реквизит = РеквизитСРодителем.Реквизит;
	РодительРеквизита = РеквизитСРодителем.Родитель;
    
	ИмяЭлемента = ?(РодительРеквизита = Неопределено, Реквизит.Имя, РодительРеквизита.Имя + Реквизит.Имя);
	
	Если ТипЗнч(Реквизит) = Тип("Объектметаданных") Тогда
		ЭтоРеквизитОбъекта = Истина;
	Иначе
		ЭтоРеквизитОбъекта = Ложь;
	КонецЕсли;

	Если ВидПоля = Неопределено И Эталон = Неопределено Тогда
		Если ЭтоРеквизитОбъекта Тогда
			СвойствоТип = "Тип";
		Иначе
			СвойствоТип = "ТипЗначения";
		КонецЕсли;

		Если Реквизит[СвойствоТип].Типы().Количество() = 1 И Реквизит[СвойствоТип].Типы()[0] = Тип("Булево") Тогда
			ВидПоля = ВидПоляФормы.ПолеФлажка;
		Иначе
			ВидПоля = ВидПоляФормы.ПолеВвода;
		КонецЕсли;
	КонецЕсли;

	Если ТипЗнч(ЭлементПередКоторымВставить) = Тип("Число") Тогда
		ГруппаДляПоискаМестаВставки = Родитель;
		Если ГруппаДляПоискаМестаВставки = Неопределено Тогда
			ГруппаДляПоискаМестаВставки = Форма;
		КонецЕсли;
		Если ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы.Количество() < ЭлементПередКоторымВставить Тогда
			ЭлементПередКоторымВставить = ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы.Количество();
		ИначеЕсли ЭлементПередКоторымВставить < 1 Тогда
			ЭлементПередКоторымВставить = 1;
		КонецЕсли;
		ЭлементПередКоторымВставить = ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы[ЭлементПередКоторымВставить - 1];	
	КонецЕсли;
	
	НовыйЭлемент = Форма.Элементы.Вставить(ИмяЭлемента, Тип("ПолеФормы"), Родитель, ЭлементПередКоторымВставить);

	Если Эталон <> Неопределено Тогда     
		ИсключаемыеСвойства = "ПутьКДанным, ПутьКДаннымПодвала, Заголовок, Подсказка, РасширеннаяПодсказка, Видимость, Доступность, ТолькоПросмотр, СочетаниеКлавиш, АктивизироватьПоУмолчанию"; 
		Если Эталон.Вид = ВидПоляФормы.ПолеВвода Тогда
			ИсключаемыеСвойства = ИсключаемыеСвойства + ", ВыделенныйТекст, СвязьПоТипу, ПодсказкаВвода, ФормаВыбора, ОтметкаНезаполненного, АвтоОтметкаНезаполненного";
		КонецЕсли;
		ЗаполнитьЗначенияСвойств(НовыйЭлемент, Эталон, , ИсключаемыеСвойства);
	КонецЕсли;
	
	Если ВидПоля <> Неопределено Тогда
		НовыйЭлемент.Вид = ВидПоля;	
	КонецЕсли;
	
	Если ЭтоРеквизитОбъекта Тогда
		Если НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода И Реквизит.ПроверкаЗаполнения = ПроверкаЗаполнения.ВыдаватьОшибку Тогда
			НовыйЭлемент.ОтметкаНезаполненного = Истина;
			НовыйЭлемент.АвтоОтметкаНезаполненного = Истина;
		КонецЕсли;
	КонецЕсли;

	НовыйЭлемент.ПутьКДанным = ПутьКДанным;

	Возврат НовыйЭлемент; 

КонецФункции

// Функция добавляет новый элемент типа КнопкаФормы
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  Команда - КомандаФормы
//  Родитель - Элемент формы, родитель для добавляемого элемента, если не указан, то добавляется на верхний уровень
//  ЭлементПередКоторымВставить - Элемент формы или Число (номер элемента формы, нумерация начинается с 1), перед которым должен быть вставлен новый элемент
//Если не указан, то элемент будет вставлен в конец
//Указание числом места вставки полезно, например, когда элемент нужно вставить в самое начало группы, а второй элемент формы может добавляться программно
//  ВидКоманды - ВидКнопкиФормы, по умолчанию ОбычнаяКнопка
//  Эталон - Элемент формы, свойства которого нужно скопировать, при этом уникальные свойства не копируются (см. переменную ИсключаемыеСвойства внутри функции) 
//
// Возвращаемое значение:
//  КнопкаФормы
//
Функция ДобавитьКнопкуФормы(Форма, Команда, Родитель = Неопределено, ЭлементПередКоторымВставить = Неопределено, ВидКоманды = Неопределено, Эталон = Неопределено)
	
	Если ВидКоманды = Неопределено И Эталон = Неопределено Тогда
		ВидКоманды = ВидКнопкиФормы.ОбычнаяКнопка;
	КонецЕсли;
	
	Если ТипЗнч(ЭлементПередКоторымВставить) = Тип("Число") Тогда
		ГруппаДляПоискаМестаВставки = Родитель;
		Если ГруппаДляПоискаМестаВставки = Неопределено Тогда
			ГруппаДляПоискаМестаВставки = Форма;
		КонецЕсли;
		Если ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы.Количество() < ЭлементПередКоторымВставить Тогда
			ЭлементПередКоторымВставить = ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы.Количество();
		ИначеЕсли ЭлементПередКоторымВставить < 1 Тогда
			ЭлементПередКоторымВставить = 1;
		КонецЕсли;
		ЭлементПередКоторымВставить = ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы[ЭлементПередКоторымВставить - 1];	
	КонецЕсли;
	
	НовыйЭлемент = Форма.Элементы.Вставить(Команда.Имя, Тип("КнопкаФормы"), Родитель, ЭлементПередКоторымВставить);

	Если Эталон <> Неопределено Тогда     
		ИсключаемыеСвойства = "ИмяКоманды, Заголовок, РасширеннаяПодсказка, КнопкаПоУмолчанию, СочетаниеКлавиш, АктивизироватьПоУмолчанию"; 
		ЗаполнитьЗначенияСвойств(НовыйЭлемент, Эталон, , ИсключаемыеСвойства);
	КонецЕсли;
	
	Если ВидКоманды <> Неопределено Тогда
		НовыйЭлемент.Вид = ВидКоманды;
	КонецЕсли;

	НовыйЭлемент.ИмяКоманды = Команда.Имя;

	Возврат НовыйЭлемент; 

КонецФункции

// Функция добавляет новый элемент типа ГруппаФормы
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  ИмяЭлемента - Строка
//  Родитель - Элемент формы, родитель для добавляемого элемента, если не указан, то добавляется на верхний уровень
//  ЭлементПередКоторымВставить - Элемент формы или Число (номер элемента формы, нумерация начинается с 1), перед которым должен быть вставлен новый элемент
//Если не указан, то элемент будет вставлен в конец
//Указание числом места вставки полезно, например, когда элемент нужно вставить в самое начало группы, а второй элемент формы может добавляться программно
//  ВидГруппы - ВидГруппыФормы, по умолчанию ОбычнаяГруппа
//  Эталон - Элемент формы, свойства которого нужно скопировать, при этом уникальные свойства не копируются (см. переменную ИсключаемыеСвойства внутри функции) 
//
// Возвращаемое значение:
//  ГруппаФормы
//
Функция ДобавитьГруппуФормы(Форма, ИмяЭлемента, Родитель = Неопределено,  ЭлементПередКоторымВставить = Неопределено, ВидГруппы = Неопределено, Эталон = Неопределено)

	Если ВидГруппы = Неопределено И Эталон = Неопределено Тогда
		ВидГруппы = ВидГруппыФормы.ОбычнаяГруппа;
	КонецЕсли;
	
	Если ТипЗнч(ЭлементПередКоторымВставить) = Тип("Число") Тогда
		ГруппаДляПоискаМестаВставки = Родитель;
		Если ГруппаДляПоискаМестаВставки = Неопределено Тогда
			ГруппаДляПоискаМестаВставки = Форма;
		КонецЕсли;
		Если ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы.Количество() < ЭлементПередКоторымВставить Тогда
			ЭлементПередКоторымВставить = ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы.Количество();
		ИначеЕсли ЭлементПередКоторымВставить < 1 Тогда
			ЭлементПередКоторымВставить = 1;
		КонецЕсли;
		ЭлементПередКоторымВставить = ГруппаДляПоискаМестаВставки.ПодчиненныеЭлементы[ЭлементПередКоторымВставить - 1];	
	КонецЕсли;
	
	НовыйЭлемент = Форма.Элементы.Вставить(ИмяЭлемента, Тип("ГруппаФормы"), Родитель, ЭлементПередКоторымВставить);

	Если Эталон <> Неопределено Тогда     
		ИсключаемыеСвойства = "Заголовок, Подсказка, СочетаниеКлавиш, ПодчиненныеЭлементы"; 
		ЗаполнитьЗначенияСвойств(НовыйЭлемент, Эталон, , ИсключаемыеСвойства);
	КонецЕсли;

	Если ВидГруппы <> Неопределено Тогда
		НовыйЭлемент.Вид = ВидГруппы;	
	КонецЕсли;
	
	НовыйЭлемент.Заголовок = ПолучитьЗаголовокПоИмени(ИмяЭлемента);

	Возврат НовыйЭлемент; 

КонецФункции

// Возвращает произвольный реквизит Формы по переданному пути
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  Путь - Строка, путь к реквизиту формы, разделенный точками (Например, Объект.Товары.Спецификация)
//
// Возвращаемое значение:
//  Структура или Неопределено, если реквизит не найден:
//   * Реквизит - РеквизитФормы или ОбъектМетаданных (реквизит объекта)
//   * Родитель - РеквизитФормы, ОбъектМетаданных (реквизит объекта) или Неопределено, если родитель (табличная часть, ТЗ или ДЗ) отсутствует     
//
Функция ПолучитьРеквизит(Форма, Путь)
	
	СтруктураВозврата = Новый Структура("Реквизит, Родитель");
	ПутьРазделенныйТочками = СтрРазделить(Путь, ".");
	Если ПутьРазделенныйТочками.Количество() > 1 И ПутьРазделенныйТочками[0] = "Объект" Тогда
		ПутьРазделенныйТочками.Удалить(0);
		Если ПутьРазделенныйТочками.Количество() = 1 Тогда
			СтруктураВозврата.Реквизит = Форма.РеквизитФормыВЗначение("Объект").Метаданные().Реквизиты[ПутьРазделенныйТочками[0]];
			Возврат СтруктураВозврата;
		Иначе
			СтруктураВозврата.Родитель = Форма.РеквизитФормыВЗначение("Объект").Метаданные().ТабличныеЧасти[ПутьРазделенныйТочками[0]];
			СтруктураВозврата.Реквизит = СтруктураВозврата.Родитель.Реквизиты[ПутьРазделенныйТочками[1]]; 
			Возврат СтруктураВозврата;	
		КонецЕсли 	
	КонецЕсли;
	МассивРеквизитов = Форма.ПолучитьРеквизиты();
	Для Каждого Стр Из МассивРеквизитов Цикл
		Если 
			ПутьРазделенныйТочками.Количество() > 1 И 
			(
			(Стр.ТипЗначения.Типы().Количество() = 1 И Стр.ТипЗначения.Типы()[0] = Тип("ТаблицаЗначений")) ИЛИ 
			(Стр.ТипЗначения.Типы().Количество() = 1 И Стр.ТипЗначения.Типы()[0] = Тип("ДеревоЗначений"))
			) 
		Тогда
			Если Стр.Имя = ПутьРазделенныйТочками[0] Тогда 
				СтруктураВозврата.Родитель = Стр;
			Иначе
				Продолжить;
			КонецЕсли;
			РеквизитыТаблицы = Форма.ПолучитьРеквизиты(Стр.Имя);
			Для Каждого СтрСтр Из РеквизитыТаблицы Цикл
				Если СтрСтр.Имя = ПутьРазделенныйТочками[1] Тогда
					СтруктураВозврата.Реквизит = СтрСтр;
					Возврат СтруктураВозврата;
				КонецЕсли;
			КонецЦикла;
		Иначе
			Если Стр.Имя = Путь Тогда
				СтруктураВозврата.Реквизит = Стр;
				Возврат СтруктураВозврата;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Возврат Неопределено;
	
КонецФункции

// Функция возвращает заголовок по наименованию так, как это происходит в конфигураторе
// При этом есть возможность убрать префикс, чтобы заголовок формировался без него
// Правила преобразования: 
//  0) удаляется префикс при необходимости (вместе с разделителем)
//  1) символ "_" заменяется пробелом, при этом лишние пробелы удаляются
//  2) первая буква становится прописной 
//  3) перед всеми прописными буквами кроме первой ставится пробел
//  4) все прописные буквы кроме первой превращаются в строчные
//
// Параметры:
//  Имя - Строка, имя написаное в стиле CamelCase с возможным указанием префикса (например, "дк_ОформитьДокументыПроизводства") 
//  РазделительПрефиксаОтИмени - Строка, по данному разделителю удаляется префикс
//  КонкретныйПрефикс - Строка, если значение заполнено, то данный префикс ищется перед разделителем, и только тогда префикс удаляется,
//если значение не заполнено, то префикс определяется автоматически перед разделителем
//
Функция ПолучитьЗаголовокПоИмени(Имя, РазделительПрефиксаОтИмени = "_", КонкретныйПрефикс = "")
	
	ИмяБезПрефикса = Имя;
	Если НЕ ЗначениеЗаполнено(КонкретныйПрефикс) И ЗначениеЗаполнено(РазделительПрефиксаОтИмени) Тогда
		КонкретныйПрефикс = Лев(Имя, Найти(Имя, РазделительПрефиксаОтИмени) - 1);	
	КонецЕсли;
	СтрокаПередКоторойВключаяУдалитьСимволы = КонкретныйПрефикс + РазделительПрефиксаОтИмени; 
	Если ЗначениеЗаполнено(СтрокаПередКоторойВключаяУдалитьСимволы) Тогда
		НачалоНужнойСтроки = Найти(Имя, СтрокаПередКоторойВключаяУдалитьСимволы);
		Если Лев(Имя, СтрДлина(СтрокаПередКоторойВключаяУдалитьСимволы)) = СтрокаПередКоторойВключаяУдалитьСимволы Тогда
			ИмяБезПрефикса = Прав(Имя, СтрДлина(Имя) - СтрДлина(СтрокаПередКоторойВключаяУдалитьСимволы));		
		КонецЕсли;
	КонецЕсли;
	
	Заголовок = "";
	ПредСимвол = "";
	Для Сч = 1 По СтрДлина(ИмяБезПрефикса) Цикл
		Символ = Сред(ИмяБезПрефикса, Сч, 1);
		Если Символ = "_" Тогда
			Символ = ?(ПредСимвол = Символы.НПП, "", Символы.НПП); 
		Иначе
			Если ВРег(Символ) = Символ Тогда
				Заголовок = Заголовок + ?(ПредСимвол = Символы.НПП, "", Символы.НПП);
			КонецЕсли;
		КонецЕсли;
		Заголовок = Заголовок + Символ; 
		ПредСимвол = ?(Символ = "", Символы.НПП, Символ);
	КонецЦикла;
	
	Заголовок = СокрЛП(ТРег(Заголовок)); 
	
	Возврат Заголовок;
	
КонецФункции


// Эту функцию корректнее размещать в клиентСерверном модуле, так как необходимость ее вызова возможна и с клиента

// Возвращает тип объекта и имя формы объекта строкой
//
// Параметры:
//  ПолноеИмяФормы - Строка, имя формы (Форма.ИмяФормы)
//
// Возвращаемое значение:
//  Структура:
//   * ТипОбъекта - Строка, содержит тип объекта (например, "ЗаказКлиента", "Номенклатура", "ОбщаяФорма")
//   * ИмяФормы - Строка, содержит конкретное имя формы (например, "ФормаДокумента", "ФормаЭлемента, "ФормаОтчета")
//
Функция ПолучитьТипОбъектаСтрокойИИмяФормы(ПолноеИмяФормы) Экспорт
	
	ЧастиИмениФормыРазделенныеТочками = СтрРазделить(ПолноеИмяФормы, ".");
	// Для разных типов объектов путь к форме может отличаться (например, общие формы)
	Если ЧастиИмениФормыРазделенныеТочками.Количество() = 2 Тогда
		ТипОбъекта = ЧастиИмениФормыРазделенныеТочками[0];
		ИмяФормы   = ЧастиИмениФормыРазделенныеТочками[1];
	ИначеЕсли ЧастиИмениФормыРазделенныеТочками.Количество() = 3 Тогда
		ТипОбъекта = ЧастиИмениФормыРазделенныеТочками[1];
		ИмяФормы   = ЧастиИмениФормыРазделенныеТочками[2]; 		
	Иначе
		ТипОбъекта = ЧастиИмениФормыРазделенныеТочками[1];
		ИмяФормы   = ЧастиИмениФормыРазделенныеТочками[3]; 
	КонецЕсли;

	Возврат Новый Структура("ТипОбъекта, ИмяФормы", ТипОбъекта, ИмяФормы);    

КонецФункции
