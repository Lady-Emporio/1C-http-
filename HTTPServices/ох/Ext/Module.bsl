﻿
//http://127.0.0.1:8080/InfoBase/ru_RU/hs/ox/show/


Функция ШаблонURL1GET(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.Заголовки.Вставить("Content-Type","text/html; charset=utf-8");
	
	Пользователь=НеИспользуетсяхСервер.ПолучитьПользователя(Запрос,Ответ);
	Если Пользователь = Неопределено тогда
		Возврат Ответ;
	КонецЕсли;
	
	ТелоОтвета="Main page OX "+Строка(ТекущаяДата())+".<br> Добро пожаловать: "+Пользователь+"<br>";
	ТелоОтвета=ТелоОтвета+"<form action="""+Константы.БазовыйПутьКСерверу.Получить()+Метаданные.HTTPСервисы.ох.КорневойURL+Метаданные.HTTPСервисы.ох.ШаблоныURL.СозданиеНовойИгры.Шаблон+
	""" method=""post""><input name=""inamegame""><input type=""hidden"" name=""hinputgame"" value=""twilight""><input type=""submit"" Value=""Созданить новую"" >";
	ТелоОтвета=ТелоОтвета+НеИспользуетсяхСервер.ШаблонТелаСписокИгр();
	Ответ.УстановитьТелоИзСтроки(ТелоОтвета);	
	Возврат Ответ;
КонецФункции

Функция ШаблонURL1POST(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки("only get. "+Строка(ТекущаяДата()));	
	Возврат Ответ;
КонецФункции

Функция ОткрытиеИгрыGET(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.Заголовки.Вставить("Content-Type","text/html; charset=utf-8");

	Ид=Запрос.ПараметрыURL["guid"];
	
	ТелоОтвета="<!Doctype html><html><head>
	|<style>
	| td{
	|	padding:10px;
	|	margin:10px;
	|}
	|</style>
	|
	|</head><body>
	|"+НеИспользуетсяхСервер.МенюИгр()+"
	|Open game:'"+Ид+"'. "+Строка(ТекущаяДата());
   	ТелоОтвета=ТелоОтвета+"<div display=none id='idgame'>"+Ид+"</div>";
	ТелоОтвета=ТелоОтвета+"<div id='status'></div>";
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Игра.Период КАК Период,
		|	Игра.guid КАК guid,
		|	Игра.ИмяИгры КАК ИмяИгры,
		|	Игра.ИграЗакрыта КАК ИграЗакрыта,
		|	Игра.Пользователь1 КАК Пользователь1,
		|	Игра.Пользователь2 КАК Пользователь2,
		|	Игра.Ход КАК Ход,
		|	Игра.НомерСтрокиТаблицы КАК НомерСтрокиТаблицы,
		|	Игра.НомерКолонкиТаблицы КАК НомерКолонкиТаблицы,
		|	Игра.Значение КАК Значение
		|ИЗ
		|	РегистрСведений.Игра КАК Игра
		|ГДЕ
		|	Игра.guid = &guid";
	
	Запрос.УстановитьПараметр("guid", Новый УникальныйИдентификатор(Ид));
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() тогда
		Ответ.УстановитьТелоИзСтроки(ТелоОтвета+"<br>Такой игры не существует");
		Возврат Ответ;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Строк=10;
	Колонок=10;
	Массив=Новый Массив(Строк,Колонок);
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Массив[ВыборкаДетальныеЗаписи.НомерСтрокиТаблицы-1][ВыборкаДетальныеЗаписи.НомерКолонкиТаблицы-1]=ВыборкаДетальныеЗаписи.Значение;
	КонецЦикла;
	ТелоОтвета=ТелоОтвета+"
	|<script>
	|function pass(elem){
	| 	url='"+Константы.БазовыйПутьКСерверу.Получить()+Метаданные.HTTPСервисы.ох.КорневойURL+Метаданные.HTTPСервисы.ох.ШаблоныURL.Data.Шаблон+"';
	|	var rowNomber=elem.dataset.row;
	|	var colNomber=elem.dataset.col;
	|	console.log(rowNomber+' '+colNomber);
	|	var idGame=document.getElementById('idgame').innerText;
	|	var sender=new XMLHttpRequest();
	|   sender.open('POST',url);
	|	sender.onload=function(){
	|		if (sender.response=='Twilight'){document.location=document.location; return;}
	|		document.getElementById('status').innerText=sender.response;	
	|	}

	|	let jsonR={
	|   	НомерСтрокиТаблицы:rowNomber,
	|   	НомерКолонкиТаблицы:colNomber,
	|   	ИдИгры:idGame
	|	};
	|	jsonS=JSON.stringify(jsonR);
	|  	sender.send(jsonS);
	|
	|
	|
	|
	|
	|
	|
	|}
	|</script>
	|";
	ТелоОтвета=ТелоОтвета+"<table style=""border: 2px solid black; border-collapse: collapse;"" >";
	Для счетчикСтрок=0 по Строк-1 цикл
		ТелоОтвета=ТелоОтвета+"<tr style=""border: 2px solid black;"" >";
		Для счетчикКолонок=0 по Колонок-1 цикл
			ЗначениеЯчейки=?(Массив[счетчикСтрок][счетчикКолонок]=Неопределено,"_" ,Массив[счетчикСтрок][счетчикКолонок]);
			ЗначениеЯчейки=?(ЗначениеЯчейки="","_",ЗначениеЯчейки);
			ТелоОтвета=ТелоОтвета+"<td style=""border: 2px solid black;"" ><button data-row='"+Формат(счетчикСтрок+1,"ЧГ=0")+"' data-col='"+Формат(счетчикКолонок+1,"ЧГ=0")+"' onclick='pass(this)'> "+ЗначениеЯчейки+"</button></td>";	
		КонецЦикла;
		ТелоОтвета=ТелоОтвета+"</tr>";
	КонецЦикла;
	ТелоОтвета=ТелоОтвета+"</table></body></html>";
	
	
	Ответ.УстановитьТелоИзСтроки(ТелоОтвета);
	Возврат Ответ;
КонецФункции


Функция ОткрытиеИгрыPOST(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки("only get. "+Строка(ТекущаяДата()));
	Возврат Ответ;
КонецФункции

Функция СозданиеНовойИгрыGET(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки("only post. "+Строка(ТекущаяДата()));
	Возврат Ответ;
КонецФункции

Функция СозданиеНовойИгрыPOST(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	
	СыроеТело=Запрос.получитьТелоКакстроку();
	СырыеДанные=СтрРазделить(СыроеТело,"&",Ложь);
	ИмяИгры=Неопределено;
	Для каждого ключИЗначЧерезРавно из СырыеДанные цикл
		КлючЗнач=СтрРазделить(ключИЗначЧерезРавно,"=",Ложь);
		Если КлючЗнач.Количество()=2 и КлючЗнач[0]="inamegame" тогда
			ИмяИгры=КлючЗнач[1];				
		КонецЕсли;
	КонецЦикла;
	Если ИмяИгры=Неопределено тогда 
		НеИспользуетсяхСервер.Вернуть404(Ответ);
		Возврат Ответ;
	КонецЕсли;
	Пользователь=НеИспользуетсяхСервер.ПолучитьПользователя(Запрос,Ответ);
	Если Пользователь=Неопределено тогда
		Возврат Ответ;
	КонецЕсли;
	Ответ.Заголовки.Вставить("Content-Type","text/html; charset=utf-8");
	ИдНовойИгры=Новый УникальныйИдентификатор();	
	Менеджер=РегистрыСведений.НеИспользуетсяИгра.СоздатьМенеджерЗаписи();
	Менеджер.Период=ТекущаяДата();
	Менеджер.guid=ИдНовойИгры;
	Менеджер.ИмяИгры=ИмяИгры;
	Менеджер.ИграЗакрыта=Ложь;
	Менеджер.Пользователь1=Пользователь;
	Менеджер.Пользователь2="";
	Менеджер.Ход=0;
	Менеджер.НомерСтрокиТаблицы=1;
	Менеджер.НомерКолонкиТаблицы=1;
	Менеджер.Значение="";
	Менеджер.Записать();
	Ответ.УстановитьТелоИзСтроки("<script type=""text/javascript"">location="""+Константы.БазовыйПутьКСерверу.Получить()+Метаданные.HTTPСервисы.ох.КорневойURL+"/"+Строка(ИдНовойИгры)+ """</script>");
	//Ответ.УстановитьТелоИзСтроки("Its post create game. "+Строка(ТекущаяДата()));
	Возврат Ответ;
КонецФункции

Функция DataGET(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки("data. "+Строка(ТекущаяДата()));
	Возврат Ответ;
КонецФункции

Функция DataPOST(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Пользователь=НеИспользуетсяхСервер.ПолучитьПользователя(Запрос,Ответ);
	Если Пользователь=Неопределено тогда
		Возврат Ответ;		
	КонецЕсли;
	JsonСырой=Запрос.ПолучитьТелоКакСтроку();
	Попытка
		Чтение=Новый ЧтениеJSON();
		Чтение.УстановитьСтроку(JsonСырой);
		Структура=  ПрочитатьJSON(Чтение);
		Чтение.Закрыть();
	Исключение
		Ответ.УстановитьТелоИзСтроки("Error json. "+Строка(ТекущаяДата()));
		Возврат Ответ;	
	КонецПопытки;
	
	
	
	
	
	
	НомерСтрокиТаблицы=Неопределено;
	НомерКолонкиТаблицы=Неопределено;
	ИдИгры=Неопределено;
	
	Если НЕ Структура.Свойство("НомерСтрокиТаблицы", НомерСтрокиТаблицы) тогда
		Ответ.УстановитьТелоИзСтроки("Error json. Not found НомерСтрокиТаблицы."+Строка(ТекущаяДата()));
		Возврат Ответ;			
	КонецЕсли;
	Если НЕ Структура.Свойство("НомерКолонкиТаблицы", НомерКолонкиТаблицы) тогда
		Ответ.УстановитьТелоИзСтроки("Error json. Not found НомерКолонкиТаблицы."+Строка(ТекущаяДата()));
		Возврат Ответ;			
	КонецЕсли;
	Если НЕ Структура.Свойство("ИдИгры", ИдИгры) тогда
		Ответ.УстановитьТелоИзСтроки("Error json. Not found ИдИгры."+Строка(ТекущаяДата()));
		Возврат Ответ;			
	КонецЕсли;
	
	Попытка
		ИдИгры=Новый УникальныйИдентификатор(ИдИгры);
		НомерСтрокиТаблицы=Число(НомерСтрокиТаблицы);	
		НомерКолонкиТаблицы=Число(НомерКолонкиТаблицы);	
	Исключение
		Ответ.УстановитьТелоИзСтроки("Error json. Неверный формат данных. "+Строка(ТекущаяДата()));
		Возврат Ответ;	
	КонецПопытки;
	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИграСрезПоследних.Пользователь1 КАК Пользователь1,
		|	ИграСрезПоследних.Пользователь2 КАК Пользователь2,
		|	ИграСрезПоследних.Значение КАК Значение,
		|	ИграСрезПоследних.Ход КАК Ход,
		|	ИграСрезПоследних.ИмяИгры КАК ИмяИгры
		|ИЗ
		|	РегистрСведений.Игра.СрезПоследних КАК ИграСрезПоследних
		|ГДЕ
		|	ИграСрезПоследних.guid = &guid";
	
	Запрос.УстановитьПараметр("guid", ИдИгры);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() тогда
		Ответ.УстановитьТелоИзСтроки("Not found id: '"+Строка(ИдИгры)+"'. "+Строка(ТекущаяДата()));
		Возврат Ответ;				
	КонецЕсли;
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ЭтоКрестик=Неопределено;
	ПоследнимХодилКрестик=Ложь;
	ДругойПользователь=Неопределено;
	ПоследнийХод=0;
	ИмяИгры="";
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ПоследнийХод=ВыборкаДетальныеЗаписи.Ход;
		ИмяИгры=ВыборкаДетальныеЗаписи.ИмяИгры;
		Если Пользователь=ВыборкаДетальныеЗаписи.Пользователь1 тогда
			ЭтоКрестик=Ложь;
			ДругойПользователь=ВыборкаДетальныеЗаписи.Пользователь2;
		ИначеЕсли Пользователь=ВыборкаДетальныеЗаписи.Пользователь2 ИЛИ ПустаяСтрока(ВыборкаДетальныеЗаписи.Пользователь2) тогда
			ЭтоКрестик=Истина;
			ДругойПользователь=ВыборкаДетальныеЗаписи.Пользователь1;
		КонецЕсли;
		
		
		Если ВыборкаДетальныеЗаписи.Значение="х" ИЛИ ПустаяСтрока(ВыборкаДетальныеЗаписи.Значение) тогда
			ПоследнимХодилКрестик=Истина;	
		КонецЕсли;
	КонецЦикла;
	Если ЭтоКрестик=Неопределено тогда
		Ответ.УстановитьТелоИзСтроки("Этот пользователь не участвует в игре. "+Строка(ТекущаяДата()));
		Возврат Ответ;			
	КонецЕсли;
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	Если ПоследнимХодилКрестик и ЭтоКрестик тогда
		Ответ.УстановитьТелоИзСтроки("Сейчас ходит нолик, а ты крестик. "+Строка(ТекущаяДата()));
		Возврат Ответ;			
	КонецЕсли;
	Если (ПоследнимХодилКрестик =Ложь) и (ЭтоКрестик=Ложь) тогда
		Ответ.УстановитьТелоИзСтроки("Сейчас ходит крестик, а ты нолик. "+Строка(ТекущаяДата()));
		Возврат Ответ;			
	КонецЕсли;

	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Игра.Значение КАК Значение
		|ИЗ
		|	РегистрСведений.Игра КАК Игра
		|ГДЕ
		|	Игра.guid = &guid
		|	И Игра.НомерСтрокиТаблицы = &НомерСтрокиТаблицы
		|	И Игра.НомерКолонкиТаблицы = &НомерКолонкиТаблицы";
	
	Запрос.УстановитьПараметр("guid", ИдИгры);
	Запрос.УстановитьПараметр("НомерКолонкиТаблицы", НомерКолонкиТаблицы);
	Запрос.УстановитьПараметр("НомерСтрокиТаблицы", НомерСтрокиТаблицы);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ВыборкаДетальныеЗаписи.Значение="0" тогда
			Ответ.УстановитьТелоИзСтроки("Клетка занята ноликом "+Строка(ТекущаяДата()));
			Возврат Ответ;		
		ИначеЕсли ВыборкаДетальныеЗаписи.Значение="х" тогда
			Ответ.УстановитьТелоИзСтроки("Клетка занята крестиком. "+Строка(ТекущаяДата()));
			Возврат Ответ;
		КонецЕсли;		
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА


	Менеджер=РегистрыСведений.НеИспользуетсяИгра.СоздатьМенеджерЗаписи();
	Менеджер.Период=ТекущаяДата();
	Менеджер.guid=ИдИгры;
	Менеджер.ИграЗакрыта=Ложь;
	Если ЭтоКрестик тогда
		Менеджер.Пользователь1=ДругойПользователь;
		Менеджер.Пользователь2=Пользователь;		
	Иначе
	Менеджер.Пользователь1=Пользователь;
	Менеджер.Пользователь2=ДругойПользователь;
	КонецЕсли;
	Менеджер.Ход=ПоследнийХод+1;
	Менеджер.НомерСтрокиТаблицы=НомерСтрокиТаблицы;
	Менеджер.НомерКолонкиТаблицы=НомерКолонкиТаблицы;
	Если НЕ ЭтоКрестик тогда
		Менеджер.Значение="0";;	
	Иначе
		Менеджер.Значение="х";	
	КонецЕсли;
	
	Менеджер.ИмяИгры=ИмяИгры;
	Менеджер.Записать();
	
	Ответ.УстановитьТелоИзСтроки("Twilight");
	Возврат Ответ;
КонецФункции


