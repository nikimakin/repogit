﻿////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ОБЪЕКТА

// Новый релиз

Процедура ОбработкаПроведения(Отказ, Режим)

	// Создание движений в регистре накопления ТоварныеЗапасы
	Движения.ТоварныеЗапасы.Записывать = Истина;
	Для каждого ТекСтрокаТовары Из Товары Цикл

		Движение = Движения.ТоварныеЗапасы.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Товар = ТекСтрокаТовары.Товар;
		Движение.Склад = Склад;
		Движение.Количество = ТекСтрокаТовары.Количество * ТекСтрокаТовары.ЕдиницаИзмерения.Коэффициент;

	КонецЦикла;

	// Создание движения в регистре накопления Взаиморасчеты
	Движения.Взаиморасчеты.Записывать = Истина;
	Движение = Движения.Взаиморасчеты.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	Движение.Период = Дата;
	Движение.Контрагент = Поставщик;
	Движение.Валюта = Валюта;
	Движение.Договор = Договор;

	Если Валюта.Пустая() Тогда

		Движение.Сумма = Товары.Итог("Сумма");

	Иначе

		Курс = РегистрыСведений.КурсыВалют.ПолучитьПоследнее(Дата, Новый Структура("Валюта", Валюта)).Курс;

		Если Курс = 0 Тогда
			Движение.Сумма = Товары.Итог("Сумма");
		Иначе
			Движение.Сумма = Товары.Итог("Сумма") / Курс;
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)

	Если ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.Контрагенты") Тогда

		ЗапросПоКонтрагенту = Новый Запрос("ВЫБРАТЬ
		                                   |	Контрагенты.ЭтоГруппа
		                                   |ИЗ
		                                   |	Справочник.Контрагенты КАК Контрагенты
		                                   |ГДЕ
		                                   |	Контрагенты.Ссылка = &КонтрагентСсылка");
		ЗапросПоКонтрагенту.УстановитьПараметр("КонтрагентСсылка", ДанныеЗаполнения);
		Выборка = ЗапросПоКонтрагенту.Выполнить().Выбрать();
		Если Выборка.Следующий() И Выборка.ЭтоГруппа Тогда
			Возврат;
		КонецЕсли;
		
		Поставщик = ДанныеЗаполнения.Ссылка;
	КонецЕсли;

КонецПроцедуры


Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	//Удалим из списка проверяемых реквизитов валюту, если по организации не ведется 
	//валютный учет
	Если НЕ ПолучитьФункциональнуюОпцию("ВалютныйУчет", Новый Структура("Организация", Организация)) Тогда
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("Валюта"));
	КонецЕсли;	
	
КонецПроцедуры

