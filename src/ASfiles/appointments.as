/*
APPOINTMENTS "LIFE CYCLE"

When you launch "appointments"	>>	MonthView.as is implemented	
	>>	MonthView.as runs createInitialChildren() which draws the monthly grid	
	>>	also, by setting currentYear, we call the createDaysGrid() which adds the corresponding cells to the grid, and displays existing appointments (if any)

***

If we click on "week view"			>>	WeekViewTimeSlots.as is implemented
	>> rebuildTimeSlots() is called (when setting timeSlots) and createIntialChildren() is called (when setting currentDate)…
	rebuildTimeSlots apparently doesn't do anything the first time, since dt (m_currentDate) is null…
	createIntialChildren calls CommonUtils.createRightHourStripTimeSlots(), which draws the weekly view, and adds any existing appointments.

***

If we click on "View appointment availability"		>>	setAvailable() is called (on appointments.as), which sets timeSlots to some values, which in turn calls the set timeSlots() or setTimeSlots() function, which calls rebuildTimeSlots() on WeekViewTimeSlots.as, which calls hCell.fillSlot(), which makes the "Click to Request" buttons available (unless there are existing appointments on those)...
If we click the "Click to Request" orange button, then DataHolder.getInstance().addEvent(obj) is called, which refreshes the views (somehow) by calling dispatchEvent(new CustomEvents(CustomEvents.ADD_NEW_EVENT)).

(if they decide they don't want the next appointment to be automatically selected, you should 1) set selected = false, 2) remove monthView.populateRightColumn(DataHolder.getInstance().dataProvider[0]);, 3) restore the removeButton Boolean, and 4) set the rightColumn.visible = false)
*/

import popups.myAppointmentsWindow;
import popups.myClassesWindow;

import calendar.classes.events.CustomEvents;
import calendar.classes.model.DataHolder;
import calendar.classes.utils.CommonUtils;
import calendar.classes.views.MonthView;

import flash.events.MouseEvent;

import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.Button;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.managers.PopUpManager;

import spark.components.Label;

[Bindable]
private var m_intCurrentDate:Date;

private var now:Date = new Date();

public var shouldAddInitialAppointments:Boolean = true;

/*ADDED BY MICHAEL*/
[Bindable] public var _timeSlots:Object = {
	'date-10-7-2011:04pm': {
		'firstSlot': true,
		'secondSlot': false
	}
}

public function onApplicationStart():void
{
	var objDate:Date = new Date();
	dtPicker.selectedDate = objDate;
	
	// create events
	monthView.addEventListener(CustomEvents.MONTH_VIEW_CLICK, onMonthViewClick);
	DataHolder.getInstance().addEventListener(CustomEvents.ADD_NEW_EVENT, onNewEventAdded);
	
	//added by Damian...
	addInitialAppointments();
	monthView.populateRightColumn(DataHolder.getInstance().dataProvider[0]);
	populateLeftColumn();
	
	onDateChange();
	
	shouldAddInitialAppointments = false;
}

/*DB*/
private function addInitialAppointments():void {
	var obj:Object = new Object();
	var today:Date = new Date();
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "11";
	obj.meridiem = "am";
	obj.mins = 0;
	obj.desc = "Physical Examination";
	obj.type = "Appointment";
	obj.selected = true;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Scheduled";
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date();
	today.setHours(0,0,0,0);
	var weekDay:Number = today.getDay();
	var daysToAddToReachFriday:Array = [5,4,3,2,1,7,6];
	today.setDate(today.date + daysToAddToReachFriday[weekDay]);	//aka "next week"
	obj.date = today;
	obj.hour = "09";
	obj.meridiem = "am";
	obj.mins = 30;
	obj.desc = "Allergies";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Greenfield";		//, Team 1
	obj.status = "Scheduled";
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date();
	today.setHours(0,0,0,0);
	var nextWeekButNotWednesday:uint = (weekDay != 3) ? 7 : 8;
	today.setDate(today.date + nextWeekButNotWednesday);	//aka "next week" (Anthony requested to make sure this doesn't happen on Wednesday, to avoid a usability test conflict with the other existing appointment on Wednesday).
	obj.date = today;
	obj.hour = "11";
	obj.meridiem = "am";
	obj.mins = 30;
	obj.desc = "Flu Vaccination";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Scheduled";
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date();
	today.setHours(0,0,0,0);
	var daysToAddToReachWednesday:Array = [3,2,1,7,6,5,4];
	today.setDate(today.date + daysToAddToReachWednesday[weekDay]);	//aka "next week"
	obj.date = today;
	obj.hour = "01";
	obj.meridiem = "pm";
	obj.mins = 00;
	obj.desc = "Physical Therapy";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Scheduled";
	DataHolder.getInstance().addEvent(obj,false);
	
	//previous appointments (from "Medical Records"):
	obj = new Object();
	today = new Date("09/16/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "11";
	obj.meridiem = "am";
	obj.mins = 0;
	obj.desc = "Physician Examination";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.nextSteps = "Yes";
	obj.nextStepsText = "•Start the Physical Rehabilitation regimen we spoke about. Our Gentle Chair Yoga class would be beneficial if you find the time.\n\n•Continue to check blood sugar twice daily.";
	obj.status = "Completed";
	obj.medRecIndex = 10;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("08/11/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "11";
	obj.meridiem = "am";
	obj.mins = 0;
	obj.desc = "Consultation";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Hammond";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 9;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("08/11/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "01";
	obj.meridiem = "pm";
	obj.mins = 0;
	obj.desc = "Surgery";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 8;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("10/16/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "11";
	obj.meridiem = "am";
	obj.mins = 0;
	obj.desc = "MRI";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 6;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("09/16/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "01";
	obj.meridiem = "pm";
	obj.mins = 0;
	obj.desc = "MRI";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 5;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("08/11/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "04";
	obj.meridiem = "pm";
	obj.mins = 0;
	obj.desc = "Blood Test";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Rothstein";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 4;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("08/11/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "07";
	obj.meridiem = "pm";
	obj.mins = 0;
	obj.desc = "Cardiac Stress Test";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Hammond";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 3;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("10/07/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "11";
	obj.meridiem = "am";
	obj.mins = 0;
	obj.desc = "Appendectomy";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 2;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("07/07/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "11";
	obj.meridiem = "am";
	obj.mins = 0;
	obj.desc = "Nasal Procedure";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 1;
	DataHolder.getInstance().addEvent(obj,false);
	
	obj = new Object();
	today = new Date("10/07/2011");
	today.setHours(0,0,0,0);
	obj.date = today;
	obj.hour = "02";
	obj.meridiem = "pm";
	obj.mins = 0;
	obj.desc = "Colonscopy";
	obj.type = "Appointment";
	obj.selected = false;
	obj.provider = "Dr. Berg";		//, Team 1
	obj.status = "Completed";
	obj.medRecIndex = 0;
	DataHolder.getInstance().addEvent(obj);
	
	//DataHolder.getInstance().updateViews();
}

/*DB*/
public function populateLeftColumn():void {
	upcomingAppts.removeAllElements();
	for(var i:uint = 0; i < DataHolder.getInstance().dataProvider.length; i++) {
		var myUpcomingApptLabel:Label = new Label();
		var obj:Object = DataHolder.getInstance().dataProvider[i];
		if(obj.status != "Completed") {
			myUpcomingApptLabel.text = obj.provider + " - " + obj.desc + "\n" + String(obj.date).substr(0,3) + ", " + String(obj.date).substr(4,3) + " " + obj.date.getDate() + ", " + (obj.meridiem != "pm" ? obj.hour : int(obj.hour) + 12) + ":" + (obj.mins == 0 ? '00' : obj.mins) + " hrs";
			//add DATE SORTING here
			upcomingAppts.addElement(myUpcomingApptLabel);
		}
	}
}

/* Custom Events */
private function onDateScroll():void
{
	onDateChange();
}

private function onDateChange():void
{
	m_intCurrentDate = new Date(dtPicker.displayedYear, dtPicker.displayedMonth, dtPicker.selectedDate.date);
}

/*private function onDayClick():void
{
stackViews.selectedIndex = 1;
}*/
private function onWeekClick():void
{
	stackViews.selectedIndex = 1;
	btnCalendarMonth.setStyle("chromeColor", 0xB3B3B3);
	btnCalendarWeek.setStyle("chromeColor", 0xFF931E);
	btnCalendarList.setStyle("chromeColor", 0xB3B3B3);
}
private function onMonthClick():void
{
	stackViews.selectedIndex = 0;
	btnCalendarMonth.setStyle("chromeColor", 0xFF931E);
	btnCalendarWeek.setStyle("chromeColor", 0xB3B3B3);
	btnCalendarList.setStyle("chromeColor", 0xB3B3B3);
}
private var wasGridDisplayedAlready:Boolean = false;
private function onListClick():void
{
	stackViews.selectedIndex = 2;
	if(wasGridDisplayedAlready) {
		appointmentsList.invalidateList();		//this refreshes the datagrid! (if the dataProvider was an ArrayCollection, should use invalidateDisplayList() instead.
	}
	wasGridDisplayedAlready = true;
	btnCalendarMonth.setStyle("chromeColor", 0xB3B3B3);
	btnCalendarWeek.setStyle("chromeColor", 0xB3B3B3);
	btnCalendarList.setStyle("chromeColor", 0xFF931E);
}

// function fires when a cell is being clicked from the Month View
private function onMonthViewClick(_event:CustomEvents):void
{
	dtPicker.selectedDate = _event.object.date;
	onDateChange();
	stackViews.selectedIndex = 0;
	btnCalendarMonth.setStyle("chromeColor", 0xFF931E);
	btnCalendarWeek.setStyle("chromeColor", 0xB3B3B3);
	btnCalendarList.setStyle("chromeColor", 0xB3B3B3);
}

// function fires when Save button is clicked from Event From to save an event
private function onNewEventAdded(_event:CustomEvents):void
{
	onDateChange();
	monthView.redraw();
}

/**
 * ADDED BY MICHAEL, EDITED BY DAMIAN
 */
public function setAvailable(set:String, reason:String):void{
	trace('clicked: '+set);
	var today:Date = new Date();
	var myDate1:String = 'date-' + (today.getMonth()+1) + '-' + today.getDate() + '-' + today.getFullYear() + ':12pm';
	var myDate2:String = 'date-' + (today.getMonth()+1) + '-' + (today.getDate()+1) + '-' + today.getFullYear() + ':10am';
	var myDate3:String = 'date-' + (today.getMonth()+1) + '-' + (today.getDate()+1) + '-' + today.getFullYear() + ':07am';
	var myDate4:String = 'date-' + (today.getMonth()+1) + '-' + (today.getDate()+7) + '-' + today.getFullYear() + ':07am';
	var myDate5:String = 'date-' + (today.getMonth()+2) + '-6-' + today.getFullYear() + ':08am';
	var myDate6:String = 'date-' + (today.getMonth()+1) + '-' + (today.getDate()+7) + '-' + today.getFullYear() + ':08am';
	var myDate7:String = 'date-' + (today.getMonth()+2) + '-6-' + today.getFullYear() + ':07am';
	
	//_timeSlots = {};
	
	if(set == 'set1'){
		_timeSlots[myDate3] = {
			'firstSlot': true,
			'secondSlot': true,
			'reason': reason,
			'type': "class",
			'has hour slot': function():String{
				return 'adsf';
			}
		};
		_timeSlots[myDate4] = {
			'firstSlot': true,
			'secondSlot': true,
			'reason': reason,
			'type': "class"
		};
		_timeSlots[myDate5] = {
			'firstSlot': true,
			'secondSlot': false,
			'reason': reason,
			'type': "class"
		};
	}else{
		/*_timeSlots = {
			'date-3-22-2012:12pm': {
				'firstSlot': true,
				'secondSlot': true,
				'reason': reason,
				'type': "appointment"
			},
			'date-3-23-2012:10am': {
				'firstSlot': false,
				'secondSlot': true,
				'reason': reason,
				'type': "appointment"
			}
		};*/
		
		_timeSlots[myDate1] = {
			'firstSlot': true,
			'secondSlot': true,
			'reason': reason,
			'type': "appointment"
		}
		_timeSlots[myDate2] = {
			'firstSlot': false,
			'secondSlot': true,
			'reason': reason,
			'type': "appointment"
		}
		_timeSlots[myDate6] = {
			'firstSlot': true,
			'secondSlot': true,
			'reason': reason,
			'type': "appointment"
		}
		_timeSlots[myDate7] = {
			'firstSlot': false,
			'secondSlot': true,
			'reason': reason,
			'type': "appointment"
		}
	}
	weekView.setTimeSlots(_timeSlots);
}

private function lblShortDate(item:Object, column:DataGridColumn):String {
	var monthLabels:Array = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	var mins:String = item.mins == 0 ? "00" : item.mins;
	return monthLabels[item.date.getMonth()] + ' ' + item.date.getDate() + ', ' + item.date.getFullYear() + ' - ' + item.hour + ':' + mins + ' ' + item.meridiem;
}
/*
private function sortByDate():void {
	(DataHolder.getInstance().dataProvider).sort = new Sort();
	DataHolder.getInstance().dataProvider.sort.fields = [new SortField("date", false, true)];
	DataHolder.getInstance().dataProvider.refresh();
}*/

/*[Bindable] public var appointmentRequested:Boolean = false;
private function requestAppointment():void {
appointmentRequested = true;

}*/

//added by damian... (obsolete)
private function displayAppointments():void {
	//...
}

private function requestAppointment():void {
	var myAppointment:myAppointmentsWindow = myAppointmentsWindow(PopUpManager.createPopUp(this, myAppointmentsWindow) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myAppointment);
	stackViews.selectedIndex = 1;
	btnCalendarMonth.setStyle("chromeColor", 0xB3B3B3);
	btnCalendarWeek.setStyle("chromeColor", 0xFF931E);
	btnCalendarList.setStyle("chromeColor", 0xB3B3B3);
}

private function requestClasses(reqClass:String = ''):void {
	var myClass:myClassesWindow = myClassesWindow(PopUpManager.createPopUp(this, myClassesWindow) as spark.components.TitleWindow);
	if(reqClass != '') myClass.showClass(reqClass);
	PopUpManager.centerPopUp(myClass);
	stackViews.selectedIndex = 1;
	btnCalendarMonth.setStyle("chromeColor", 0xB3B3B3);
	btnCalendarWeek.setStyle("chromeColor", 0xFF931E);
	btnCalendarList.setStyle("chromeColor", 0xB3B3B3);
}

private function appointmentsListSelection():void {
	monthView.handleApptSelection(appointmentsList.selectedItem);
}

/*didn't work.. using stackViews.creationPolicy="all" instead, along with monthView's parentApplication.appointmentsList.selectedItem = obj;
private function appointmentsListAutoSelect():void {
	for(var i:uint = 0; i < DataHolder.getInstance().dataProvider.length; i++) {
		if(DataHolder.getInstance().dataProvider[i].selected == true) appointmentsList.selectedItem = DataHolder.getInstance().dataProvider[i];
	}
}*/