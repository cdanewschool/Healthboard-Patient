package external.calendar.classes.views
{
	import components.appointments.monthViewLinkButton;
	import components.appointments.myConfirmCancelWindow;
	
	import external.calendar.classes.events.CustomEvents;
	import external.calendar.classes.model.DataHolder;
	import external.calendar.classes.utils.CommonUtils;
	import external.calendar.mxml_views.monthCell;
	
	import flash.events.MouseEvent;
	
	import mx.containers.ApplicationControlBar;
	import mx.containers.Canvas;
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.containers.HBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import skins.appointments.MyLinkButtonSkin;
	
	import spark.components.TitleWindow;
	
	/**
	 * THIS CLASS WILL ALLOW TO GENERATE A GRID OF CURRENT MONTH
	 *
	 * THIS CLASS USES monthCell TO REPRESENT A SINGLE DAY.
	 *
	 * ADDITIONALLY IT CONNECTS WITH DATA HOLDER AND CHECK FOR EVENT EXISTENSE FOR A PARTICULAR
	 * DATE AND GENERATE THE VIEW ACCORDINGLY.
	 *
	 * THIS CLASS IS EXTENDED TO CANVAS SO IT COULD BE USED A DISPLAY OBJECT IN MXML FILES AS WELL.
	 */
	
	public class MonthView extends Canvas
	{
		
		private var m_intCurrentMonth:int;
		private var m_intCurrentYear:int;
		
		private var m_monthViewGrid:Grid;
		private var m_appBar:ApplicationControlBar
		private var m_lblDaysNames:Label;
		private var m_monthName:Label;		//added DB
		
		public function MonthView()
		{
			super();
			createIntialChildren();
		}
		
		// function responsible for generating the view
		private function createIntialChildren():void
		{
			// add a new grid
			m_monthViewGrid = new Grid();
			m_monthViewGrid.styleName = "grdMonthView";
			m_monthViewGrid.y = 55;
			
			// add application bar which will show days name on the top of the view
			m_appBar = new ApplicationControlBar();
			m_appBar.width = 800;
			m_appBar.height = 22;
			m_appBar.styleName = "appBarDayCell";
			
			m_lblDaysNames = new Label();
			m_lblDaysNames.y = 33;
			m_lblDaysNames.width = 775;
			m_lblDaysNames.height = 16;
			m_lblDaysNames.styleName = "lblDaysNames";
			m_lblDaysNames.text = "            Sunday                        Monday                       Tuesday                    Wednesday                   Thursday                        Friday                        Saturday";
			
			m_monthName = new Label();
			m_monthName.styleName = "subtitles";
			m_monthName.horizontalCenter = 0;
			m_monthName.y = 2;
			
			//this.addChild(m_appBar);
			//m_appBar.addChild(m_lblDaysNames);
			this.addChild(m_monthName);
			this.addChild(m_lblDaysNames);
			this.addChild(m_monthViewGrid);
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		// create grid of days in current month as per current date provided
		private function createDaysGrid():void
		{
			// always assume that first day of a month will have date as 1
			// currentMonth and currentYear are supplied by main.mxml file
			var objDate:Date = new Date(currentYear, currentMonth, 1);
			
			// get total days count for currentMonth in currentYear
			var intTotalDaysInMonth:int = CommonUtils.getDaysCount(currentMonth, currentYear);
			var i:int;
			
			m_monthName.text = getMonthName(objDate.month) + " " + currentYear;
			
			/**
			 * Add Total number of Grid items in a Array
			 *
			 **/
			
			// add empty items in case first day is not Sunday
			// i.e. MonthView always shows 7 columns starting from Sunday and ending to Saturday
			// so if it suppose Wednesday is the date 1 of this month that means we need to
			// add 3 empty cells at start
			var arrDays:Array = new Array();
			for(i=0; i<objDate.getDay(); i++)
			{
				arrDays.push(-1);
			}
			
			// now loop through total number of days in this month and save values in array
			for(i=0; i<intTotalDaysInMonth; i++)
			{
				var objDate1:Date = new Date(currentYear, currentMonth, (i+1));
				var strStartDayName:String = CommonUtils.getDayName(objDate1.getDay());
				arrDays.push({data:i+1, label:strStartDayName});
			}
			
			// if first day of the month is Friday and it is not a leap year then we need to show 7 rows
			// there could be max 42 items in a calendar grid for a month with 6 rows
			// so add blank values in case still some cells are pending as per count of 7 cols x 6 rows = 42
			if(objDate.getDay() >= 5 && arrDays.length <= 32)
			{
				for(i=arrDays.length; i<42; i++)
				{
					arrDays.push(-1);
				}
			}
			else
			{
				for(i=arrDays.length; i<35; i++)
				{
					arrDays.push(-1);
				}
			}
			
			m_monthViewGrid.removeAllChildren();
			
			var objGridRow:GridRow;
			
			// once array is created now loop through the array and generate the Grid
			var cellHeight:int = arrDays.length == 35 ? 106 : 88;
			for(i=0; i<arrDays.length; i++)
			{
				if(i % 7 == 0)
				{
					objGridRow = new GridRow();
					m_monthViewGrid.addChild(objGridRow);
				}
				
				var objGridItem:GridItem = new GridItem();
				var objDayCell:monthCell = new monthCell();
				
				var myCount:uint = 1;
				
				objDayCell.height = cellHeight;
				
				objGridItem.addChild(objDayCell);
				objGridRow.addChild(objGridItem);
				
				//objDayCell.txtDesc.visible = false;
				
				if(arrDays[i] == -1) //if it's one of the "empty days" (either before or after the 28-31 days in the month)
				{
					objDayCell.canHeader.visible = false;		//COMMENTING THIS LINE OUT WAS CREATING THE ERROR THAT THE DAYS DON'T SHOW PROPERLY...	
					//objDayCell.visible = false;
				}
				else
				{
					objDayCell.lblDate.text = arrDays[i].data;
					//objDayCell.addEventListener(MouseEvent.CLICK, onDayCellClick);	//commented out DB
					objDayCell.data = {date: new Date(currentYear, currentMonth, arrDays[i].data)};
					
					var today:Date = new Date();
					today.setHours(0,0,0,0);
					if(ObjectUtil.dateCompare(today,objDayCell.data.date) == 0) {
						objDayCell.lblDate.styleName = "calendarSelectedDay";
						objDayCell.styleName = "calendarSelectedCell";
					}

					// check if current date has some event stored in DataHolder
					// if YES then display event description
					for(var j:int=0; j<DataHolder.getInstance().dataProvider.length; j++)
					{
						var obj:Object = DataHolder.getInstance().dataProvider[j];
						if(ObjectUtil.dateCompare(obj.date, objDayCell.data.date) == 0) {
							var myLinkButton:LinkButton = new monthViewLinkButton();
							myLinkButton.label = (obj.meridiem != "pm" ? obj.hour : int(obj.hour) + 12) + ":" + (obj.mins == 0 ? '00' : obj.mins) + " " + (obj.type == "Appointment" ? obj.provider : obj.desc);
							myLinkButton.selected = obj.selected;
							myLinkButton.addEventListener(MouseEvent.CLICK,func(obj));
							myLinkButton.top = 25 + 15*(myCount-1);	//here we're setting the top margin equal to 25, 40, 55, 70, etc respectively...		 //myCount == 1 ? 25 : 25*(myCount*.8);
							objDayCell.addChild(myLinkButton);
							/*if(obj.selected) {
								objDayCell.lblDate.styleName = "calendarSelectedDay";
								objDayCell.styleName = "calendarSelectedCell";
							}*/
							
							myCount++;
							//break;
						}
					}
				}
			}
		}
		
		public function redraw():void
		{
			createDaysGrid();
		}
		
		//DB
		//see http://nwebb.co.uk/blog/?p=243
		private function func(myObj:Object):Function {
			return function(mouseEvent:MouseEvent):void {
				handleApptSelection(myObj);		//set this appointment = selected, and all the others = not selected (and also updates the right column)
				
				var objDayCell:monthCell = monthCell(mouseEvent.target.parent);		//this selects the day in the calendar
				dispatchEvent(new CustomEvents(CustomEvents.MONTH_VIEW_CLICK, objDayCell.data));
			}
		}
		
		//DB
		private var myBtnCancelAppt:Button;
		//private var removeButton:Boolean = false;
		
		public var selectedApptType:String = "appointment";		//used to send the appropriate parameter to the messages module when creating a new messages from the appts module.
		public var selectedApptMedRecIndex:int;					//used to send the appropriate parameter to the medical records module...
		
		public function handleApptSelection(selectedObject:Object):void {
			for(var i:uint = 0; i < DataHolder.getInstance().dataProvider.length; i++) {
				var obj:Object = DataHolder.getInstance().dataProvider[i];
				if(obj == selectedObject) {
					obj.selected = true;
					parentApplication.rightColumn.visible = parentApplication.rightColumn.includeInLayout = true;
					parentApplication.rightColumnEventCanceled.visible = parentApplication.rightColumnEventCanceled.includeInLayout = false;
					parentApplication.appointmentProvider.text = obj.type == "Appointment" ? obj.provider : obj.desc;
					parentApplication.appointmentDateStart.text = String(obj.date).substr(4,3) + " " + obj.date.getDate() + ", " + obj.date.getFullYear() + " at " + (obj.meridiem != "pm" ? obj.hour : int(obj.hour) + 12) + ":" + (obj.mins == 0 ? '00' : obj.mins);
					parentApplication.appointmentDateEnd.text = String(obj.date).substr(4,3) + " " + obj.date.getDate() + ", " + obj.date.getFullYear() + " at " + (obj.mins == 0 ? (obj.meridiem != "pm" ? obj.hour : int(obj.hour) + 12) : (obj.meridiem != "pm" ? int(obj.hour) : int(obj.hour) + 12) + 1) + ":" + (obj.mins == 0 ? '30' : '00');
					if(obj.type == "Appointment") {
						parentApplication.appointmentDetails.visible = parentApplication.appointmentDetails.includeInLayout = true;
						parentApplication.classDetails.visible = parentApplication.classDetails.includeInLayout = false;
						parentApplication.appointmentType.text = "Routine";
						parentApplication.appointmentRFV.text = obj.desc;
						parentApplication.btnAppointmentMessage.label = "Message " + obj.provider;
						selectedApptType = "appointment";
						
						if(obj.nextSteps == "Yes") {
							parentApplication.vgNextSteps.visible = parentApplication.vgNextSteps.includeInLayout = parentApplication.nextStepsLine.visible = parentApplication.nextStepsLine.includeInLayout = true;
							parentApplication.lblNextSteps.text = obj.nextStepsText;
						}
						else parentApplication.vgNextSteps.visible = parentApplication.vgNextSteps.includeInLayout = parentApplication.nextStepsLine.visible = parentApplication.nextStepsLine.includeInLayout = false;
						
						if(obj.status == "Completed") {
							parentApplication.hgViewMedRec.visible = parentApplication.hgViewMedRec.includeInLayout = true;
							selectedApptMedRecIndex = obj.medRecIndex;
						}
						else parentApplication.hgViewMedRec.visible = parentApplication.hgViewMedRec.includeInLayout = false;
						
					}
					else {
						parentApplication.appointmentDetails.visible = parentApplication.appointmentDetails.includeInLayout = false;
						parentApplication.classDetails.visible = parentApplication.classDetails.includeInLayout = true;
						parentApplication.appointmentType.text = "Class";
						parentApplication.classInstructor.text = obj.provider;
						parentApplication.btnAppointmentMessage.label = "Message class instructor";
						selectedApptType = "class";
					}
					
					parentApplication.hgCancelAppt.removeElement(myBtnCancelAppt);		//if(removeButton) 
					myBtnCancelAppt = new Button();
					myBtnCancelAppt.label = obj.type == "Appointment" ? "- Cancel Appointment" : "- Cancel Reservation";
					myBtnCancelAppt.height=24;
					myBtnCancelAppt.styleName="buttonText";
					myBtnCancelAppt.addEventListener(MouseEvent.CLICK,func2(obj));
					parentApplication.hgCancelAppt.addElement(myBtnCancelAppt);
					//removeButton = true;
					/*Alert.show("Previous?: " + currentObjectPassedToEventListener.desc);
					parentApplication.btnCancelAppointment.removeEventListener(MouseEvent.CLICK,func2(currentObjectPassedToEventListener));
					parentApplication.btnCancelAppointment.addEventListener(MouseEvent.CLICK,func2(obj));
					currentObjectPassedToEventListener = obj;*/
					
					parentApplication.appointmentsList.selectedItem = obj;	//update the list view's selection = the selected object (we're also setting the viewStack.creationPolicy=all to avoid this line from creating an error in case appointmentsList wasn't created yet)
				}
				else obj.selected = false;
			}
			redraw();
		}
				
		public function sendMessage(type:String):void {
			parentApplication.currentState = 'modMessages';
			if(parentApplication.howToHandleMessageTabs != "not created") {		//howToHandleMessageTabs is a fix; if we call createNewMessage from the appointments module (i.e. sending a msg to a doctor or nurse) or viewMessage from the Widgets module before the messages module has been created, then it messes up everything... so, the first time we want to createNewMessage from appts or viewMessage from Widgets, we just set it to "viewWidgetMessage" or "createApptsMessage", and the corresponding function will be called from the messages module instead...
				var recipient:uint = type == "appointment" ? 1 : 2;
				parentApplication.createNewMessage(recipient);
				parentApplication.tabsMessages.selectedIndex = parentApplication.viewStackMessages.length - 2;
			}
			else parentApplication.howToHandleMessageTabs = "createApptsMessage";
		}
		
		public function viewMedicalRecord(index:int):void {
			if(!parentApplication.wasModuleCreated) parentApplication.medicalRecordsXMLdata.send();
			parentApplication.currentState = 'modMedicalRecords';
			
			if(parentApplication.wasModuleCreated) parentApplication.viewServiceDetails(parentApplication.medicalRecordsData.getItemAt(index));
			else parentApplication.wasModuleCreated = true;	//this is important, because it makes the handleIfFromAppts() from appointments.as run the viewServiceDetails() function.
		}
		
		//private var currentObjectPassedToEventListener:Object = new Object();
		
		//DB
		//see http://nwebb.co.uk/blog/?p=243
		public function func2(myObj:Object):Function {
			return function(mouseEvent:MouseEvent):void {
				confirmCancel(myObj);
				//Alert.show("kakashka " + myObj.desc);
			}
		}
		
		/*DB*/
		public function populateRightColumn(obj:Object):void {
			parentApplication.appointmentProvider.text = obj.provider;
			parentApplication.appointmentDateStart.text = String(obj.date).substr(4,3) + " " + obj.date.getDate() + ", " + obj.date.getFullYear() + " at " + (obj.meridiem != "pm" ? obj.hour : int(obj.hour) + 12) + ":" + (obj.mins == 0 ? '00' : obj.mins);
			parentApplication.appointmentDateEnd.text = String(obj.date).substr(4,3) + " " + obj.date.getDate() + ", " + obj.date.getFullYear() + " at " + (obj.mins == 0 ? (obj.meridiem != "pm" ? obj.hour : int(obj.hour) + 12) : (obj.meridiem != "pm" ? int(obj.hour) : int(obj.hour) + 12) + 1) + ":" + (obj.mins == 0 ? '30' : '00');
			parentApplication.appointmentType.text = obj.type == "Appointment" ? "Routine" : "Class";		//initially routine...
			parentApplication.appointmentRFV.text = obj.desc;
			parentApplication.btnAppointmentMessage.label = "Message " + obj.provider;
			
			myBtnCancelAppt = new Button();
			myBtnCancelAppt.label = "- Cancel Appointment";
			myBtnCancelAppt.height=24;
			myBtnCancelAppt.styleName="buttonText";
			myBtnCancelAppt.addEventListener(MouseEvent.CLICK,func2(obj));
			parentApplication.hgCancelAppt.addElement(myBtnCancelAppt);
		}
		
		//DB
		private function confirmCancel(myObj:Object):void {
			var myAlert:myConfirmCancelWindow = myConfirmCancelWindow(PopUpManager.createPopUp(this, myConfirmCancelWindow) as spark.components.TitleWindow);
			myAlert.apptToCancel = myObj;
			PopUpManager.centerPopUp(myAlert);
		}
		
		
		// click event for a day cell
		// will change the view to Day View and set current date as per cell clicked in the Grid
		/*	//(DB replaced this with the above function, since we are currently only allowing selections from appointments--not from empty cells)
		private function onDayCellClick(_event:MouseEvent):void
		{
			var objDayCell:monthCell
			if(_event.target.toString().indexOf("txtDesc") == -1)
			{
				objDayCell = monthCell(_event.target);
			}
			else
			{
				objDayCell = monthCell(_event.target.parent.parent);
			}
			dispatchEvent(new CustomEvents(CustomEvents.MONTH_VIEW_CLICK, objDayCell.data));
		}*/
		
		/**
		 * Custom Properties
		 *
		 **/
		public function set currentMonth(_intCurrentMonth:int):void
		{
			m_intCurrentMonth = _intCurrentMonth;
		}
		
		public function get currentMonth():int
		{
			return m_intCurrentMonth;
		}
		
		public function set currentYear(_intCurrentYear:int):void
		{
			m_intCurrentYear = _intCurrentYear;
			createDaysGrid();
		}
		
		public function get currentYear():int
		{
			return m_intCurrentYear;
		}
		
		/*DB*/
		private function getMonthName(month:int):String {
			var arrMonths:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
			return arrMonths[month];
		}
	}
}
